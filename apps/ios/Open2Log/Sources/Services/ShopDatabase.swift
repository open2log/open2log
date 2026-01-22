import Foundation
import CoreLocation

/// Local database for caching shop data for offline use
actor ShopDatabase {
    private var shops: [Shop] = []

    /// Load shops from local storage
    func load() async {
        // Load from SwiftData or local file
    }

    /// Save shops to local storage
    func save() async {
        // Persist to SwiftData or local file
    }

    /// Update shops from API
    func update(shops: [Shop]) async {
        self.shops = shops
        await save()
    }

    /// Get all shops
    func allShops() async -> [Shop] {
        shops
    }

    /// Get shops near a location
    func shopsNear(latitude: Double, longitude: Double, radiusKm: Double) async -> [Shop] {
        let center = CLLocation(latitude: latitude, longitude: longitude)
        let radiusMeters = radiusKm * 1000

        return shops.filter { shop in
            shop.distance(from: center) <= radiusMeters
        }
    }

    /// Get shop by GERS ID
    func shop(byGersId gersId: String) async -> Shop? {
        shops.first { $0.gersId == gersId }
    }

    /// Get shop by ID
    func shop(byId id: UUID) async -> Shop? {
        shops.first { $0.id == id }
    }
}
