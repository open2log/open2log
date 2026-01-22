import Foundation

struct Product: Codable, Identifiable {
    let id: UUID
    let ean: String?
    let sku: String?
    let name: String
    let brand: String?
    let description: String?
    let category: String?
    let unitSize: Double?
    let unitType: UnitType?
    let imageUrl: String?
    let source: ProductSource
    let matchConfidence: Double?
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case id, ean, sku, name, brand, description, category
        case unitSize = "unit_size"
        case unitType = "unit_type"
        case imageUrl = "image_url"
        case source
        case matchConfidence = "match_confidence"
        case voteCount = "vote_count"
    }
}

enum UnitType: String, Codable {
    case g, kg, ml, l, pcs
}

enum ProductSource: String, Codable {
    case crawled
    case userSubmitted = "user_submitted"
}
