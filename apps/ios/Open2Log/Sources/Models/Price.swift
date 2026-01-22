import Foundation

struct Price: Codable, Identifiable {
    let id: UUID
    let productId: UUID
    let shopId: UUID
    let userId: UUID?
    let priceCents: Int
    let currency: String
    let unitPriceCents: Int?
    let comparisonUnit: UnitType?
    let source: PriceSource
    let scannedAt: Date?
    let barcodeImageUrl: String?
    let priceImageUrl: String?
    let validFrom: Date?
    let validUntil: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case shopId = "shop_id"
        case userId = "user_id"
        case priceCents = "price_cents"
        case currency
        case unitPriceCents = "unit_price_cents"
        case comparisonUnit = "comparison_unit"
        case source
        case scannedAt = "scanned_at"
        case barcodeImageUrl = "barcode_image_url"
        case priceImageUrl = "price_image_url"
        case validFrom = "valid_from"
        case validUntil = "valid_until"
        case createdAt = "created_at"
    }

    var priceFormatted: String {
        let euros = Double(priceCents) / 100.0
        return String(format: "%.2f €", euros)
    }
}

enum PriceSource: String, Codable {
    case crawled
    case userScanned = "user_scanned"
}
