import Foundation
import AVFoundation
import Vision
import UIKit

/// Handles barcode scanning using device camera and Vision framework
class BarcodeScanner: NSObject, ObservableObject {
    @Published var scannedBarcode: String?
    @Published var isScanning: Bool = false
    @Published var error: String?

    private var captureSession: AVCaptureSession?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let barcodeQueue = DispatchQueue(label: "BarcodeScanner")

    // For extracting barcode region from image
    private var lastBarcodeRect: CGRect?
    private var lastFrameBuffer: CVPixelBuffer?

    override init() {
        super.init()
    }

    func setupCamera() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()
                    }
                }
            }
            return
        }
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            error = "Failed to access camera"
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        videoOutput.setSampleBufferDelegate(self, queue: barcodeQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        captureSession = session
    }

    func startScanning() {
        scannedBarcode = nil
        isScanning = true
        barcodeQueue.async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func stopScanning() {
        isScanning = false
        captureSession?.stopRunning()
    }

    var previewLayer: AVCaptureVideoPreviewLayer? {
        guard let session = captureSession else { return nil }
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }

    /// Extract the barcode region as AVIF image data
    func extractBarcodeImage() -> Data? {
        guard let buffer = lastFrameBuffer,
              let rect = lastBarcodeRect else { return nil }

        let ciImage = CIImage(cvPixelBuffer: buffer)
        let context = CIContext()

        // Convert normalized rect to pixel coordinates
        let width = CGFloat(CVPixelBufferGetWidth(buffer))
        let height = CGFloat(CVPixelBufferGetHeight(buffer))

        let cropRect = CGRect(
            x: rect.origin.x * width,
            y: rect.origin.y * height,
            width: rect.width * width,
            height: rect.height * height
        )

        guard let cgImage = context.createCGImage(ciImage, from: cropRect) else { return nil }

        let uiImage = UIImage(cgImage: cgImage)

        // Encode as AVIF using ImageIO
        return encodeAsAVIF(uiImage)
    }

    private func encodeAsAVIF(_ image: UIImage) -> Data? {
        // Use HEIC as fallback if AVIF not available
        // iOS 16+ supports AVIF encoding
        guard let cgImage = image.cgImage else { return nil }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data,
            "public.avif" as CFString, // Use AVIF
            1,
            nil
        ) else {
            // Fallback to HEIC
            guard let heicDest = CGImageDestinationCreateWithData(
                data,
                "public.heic" as CFString,
                1,
                nil
            ) else { return nil }
            CGImageDestinationAddImage(heicDest, cgImage, nil)
            CGImageDestinationFinalize(heicDest)
            return data as Data
        }

        CGImageDestinationAddImage(destination, cgImage, nil)
        CGImageDestinationFinalize(destination)
        return data as Data
    }
}

extension BarcodeScanner: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isScanning,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let results = request.results as? [VNBarcodeObservation],
                  let barcode = results.first,
                  let payload = barcode.payloadStringValue else { return }

            DispatchQueue.main.async {
                self?.lastFrameBuffer = pixelBuffer
                self?.lastBarcodeRect = barcode.boundingBox
                self?.scannedBarcode = payload
                self?.stopScanning()
            }
        }

        // Support common barcode formats
        request.symbologies = [.ean8, .ean13, .upce, .code128, .code39, .qr]

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
