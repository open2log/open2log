import Foundation
import SwiftData

/// Represents a pending price/product upload stored locally until network is available
@Model
final class PendingUpload {
    @Attribute(.unique) var id: UUID
    var ean: String?
    var productName: String?
    var priceCents: Int
    var shopGersId: String
    var scannedAt: Date

    // Local image paths
    var barcodeImagePath: String?
    var priceImagePath: String?
    var productImagePath: String?

    // Upload status
    var uploadAttempts: Int = 0
    var lastAttemptAt: Date?
    var error: String?

    // Status tracking
    var barcodeImageUploaded: Bool = false
    var priceImageUploaded: Bool = false
    var productImageUploaded: Bool = false
    var dataUploaded: Bool = false

    init(
        id: UUID = UUID(),
        ean: String? = nil,
        productName: String? = nil,
        priceCents: Int,
        shopGersId: String,
        scannedAt: Date = Date(),
        barcodeImagePath: String? = nil,
        priceImagePath: String? = nil,
        productImagePath: String? = nil
    ) {
        self.id = id
        self.ean = ean
        self.productName = productName
        self.priceCents = priceCents
        self.shopGersId = shopGersId
        self.scannedAt = scannedAt
        self.barcodeImagePath = barcodeImagePath
        self.priceImagePath = priceImagePath
        self.productImagePath = productImagePath
    }

    var isComplete: Bool {
        dataUploaded &&
        (barcodeImagePath == nil || barcodeImageUploaded) &&
        (priceImagePath == nil || priceImageUploaded) &&
        (productImagePath == nil || productImageUploaded)
    }

    var canRetry: Bool {
        uploadAttempts < 10
    }
}
