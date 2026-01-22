import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let status: String
    let memberSince: Date?
    let bankReference: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, email, status
        case memberSince = "member_since"
        case bankReference = "bank_reference"
        case createdAt = "created_at"
    }
}
