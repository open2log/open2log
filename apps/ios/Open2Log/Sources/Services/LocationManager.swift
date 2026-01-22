import Foundation
import CoreLocation
import Combine

/// Manages location services and detects nearby shops
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var shopDatabase: ShopDatabase?

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var nearbyShops: [Shop] = []
    @Published var detectedShop: Shop?

    // Threshold for considering user "at" a shop (meters)
    private let shopDetectionRadius: CLLocationDistance = 50

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }

    func setShopDatabase(_ database: ShopDatabase) {
        self.shopDatabase = database
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        currentLocation = location
        updateNearbyShops(for: location)
        detectCurrentShop(for: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    // MARK: - Shop Detection

    private func updateNearbyShops(for location: CLLocation) {
        guard let database = shopDatabase else { return }

        // Get shops within configured radius
        Task {
            let shops = await database.shopsNear(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                radiusKm: 5.0
            )

            await MainActor.run {
                self.nearbyShops = shops.sorted { shop1, shop2 in
                    shop1.distance(from: location) < shop2.distance(from: location)
                }
            }
        }
    }

    private func detectCurrentShop(for location: CLLocation) {
        // Find if user is within detection radius of any shop
        let detectedShops = nearbyShops.filter { shop in
            shop.distance(from: location) <= shopDetectionRadius
        }

        // Pick the closest one
        let closest = detectedShops.min { shop1, shop2 in
            shop1.distance(from: location) < shop2.distance(from: location)
        }

        if closest?.id != detectedShop?.id {
            detectedShop = closest
        }
    }
}
