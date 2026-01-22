import SwiftUI
import AVFoundation

struct ScanView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var scanner = BarcodeScanner()
    @State private var showPriceEntry = false
    @State private var capturedPriceImage: UIImage?
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let shop = appState.currentShop {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.green)
                        Text("At: \(shop.name)")
                            .font(.subheadline)

                        Spacer()

                        Button("Change") {
                            appState.currentShop = nil
                        }
                        .font(.caption)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                } else {
                    HStack {
                        Image(systemName: "location.slash")
                            .foregroundStyle(.orange)
                        Text("Select a shop from the map first")
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                }

                if scanner.isScanning {
                    BarcodeScannerView(scanner: scanner)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding()
                } else if let barcode = scanner.scannedBarcode {
                    ScannedBarcodeView(barcode: barcode) {
                        showPriceEntry = true
                    } onRescan: {
                        scanner.startScanning()
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)

                        Text("Scan a product barcode")
                            .font(.headline)

                        Text("Position the barcode within the camera frame")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button {
                            scanner.setupCamera()
                            scanner.startScanning()
                        } label: {
                            Label("Start Scanning", systemImage: "camera")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(appState.currentShop == nil)
                    }
                    .padding()
                }

                if appState.pendingUploads > 0 {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("\(appState.pendingUploads) pending uploads")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .navigationTitle("Scan")
            .sheet(isPresented: $showPriceEntry) {
                if let barcode = scanner.scannedBarcode, let shop = appState.currentShop {
                    PriceEntryView(
                        barcode: barcode,
                        shop: shop,
                        barcodeImage: scanner.extractBarcodeImage()
                    ) {
                        scanner.scannedBarcode = nil
                    }
                }
            }
        }
    }
}

struct BarcodeScannerView: UIViewRepresentable {
    @ObservedObject var scanner: BarcodeScanner

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black

        if let previewLayer = scanner.previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

struct ScannedBarcodeView: View {
    let barcode: String
    let onContinue: () -> Void
    let onRescan: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Barcode Scanned!")
                .font(.headline)

            Text(barcode)
                .font(.title2.monospaced())
                .padding()
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 16) {
                Button("Rescan", action: onRescan)
                    .buttonStyle(.bordered)

                Button("Enter Price", action: onContinue)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

struct PriceEntryView: View {
    let barcode: String
    let shop: Shop
    let barcodeImage: Data?
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var priceEuros = ""
    @State private var priceCents = ""
    @State private var priceImage: UIImage?
    @State private var productImage: UIImage?
    @State private var showPriceCamera = false
    @State private var showProductCamera = false
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    HStack {
                        Text("Barcode")
                        Spacer()
                        Text(barcode)
                            .font(.body.monospaced())
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Shop")
                        Spacer()
                        Text(shop.name)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Price") {
                    HStack {
                        TextField("0", text: $priceEuros)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)

                        Text(",")

                        TextField("00", text: $priceCents)
                            .keyboardType(.numberPad)
                            .frame(width: 40)

                        Text("€")
                    }
                    .font(.title)
                }

                Section("Price Label Photo") {
                    if let image = priceImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)

                        Button("Retake") {
                            showPriceCamera = true
                        }
                    } else {
                        Button {
                            showPriceCamera = true
                        } label: {
                            Label("Take Photo of Price", systemImage: "camera")
                        }
                    }
                }

                Section("Product Photo (optional)") {
                    if let image = productImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)

                        Button("Retake") {
                            showProductCamera = true
                        }
                    } else {
                        Button {
                            showProductCamera = true
                        } label: {
                            Label("Take Photo of Product", systemImage: "camera")
                        }
                    }
                }
            }
            .navigationTitle("Enter Price")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePrice()
                    }
                    .disabled(!isValid || isSubmitting)
                }
            }
            .sheet(isPresented: $showPriceCamera) {
                ImagePicker(image: $priceImage)
            }
            .sheet(isPresented: $showProductCamera) {
                ImagePicker(image: $productImage)
            }
        }
    }

    private var isValid: Bool {
        guard let euros = Int(priceEuros), euros >= 0,
              let cents = Int(priceCents), cents >= 0, cents < 100 else {
            return false
        }
        return true
    }

    private var priceCentsValue: Int {
        let euros = Int(priceEuros) ?? 0
        let cents = Int(priceCents) ?? 0
        return euros * 100 + cents
    }

    private func savePrice() {
        isSubmitting = true
        // Save to local database for later sync
        // PendingUpload will be created and synced when network is available

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSubmitting = false
            onComplete()
            dismiss()
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
