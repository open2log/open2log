import Foundation
import CoreLocation

struct Shop: Codable, Identifiable {
    let id: UUID
    let gersId: String? // Overture Maps GERS ID
    let name: String
    let chain: ShopChain
    let address: String
    let city: String
    let postalCode: String
    let country: String
    let latitude: Double
    let longitude: Double
    let h3Index: String?
    let openingHours: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id
        case gersId = "gers_id"
        case name, chain, address, city
        case postalCode = "postal_code"
        case country, latitude, longitude
        case h3Index = "h3_index"
        case openingHours = "opening_hours"
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    func distance(from location: CLLocation) -> CLLocationDistance {
        self.location.distance(from: location)
    }
}

enum ShopChain: String, Codable, CaseIterable {
    case lidl
    case sKaupat = "s_kaupat"
    case kMarket = "k_market"
    case tokmanni
    case prisma
    case other

    var displayName: String {
        switch self {
        case .lidl: return "Lidl"
        case .sKaupat: return "S-kaupat"
        case .kMarket: return "K-market"
        case .tokmanni: return "Tokmanni"
        case .prisma: return "Prisma"
        case .other: return "Other"
        }
    }
}
