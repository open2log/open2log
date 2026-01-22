import Foundation
import Combine

/// Global application state
class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var userStatus: UserStatus = .waitlist
    @Published var isOnboarded: Bool = false

    // Settings
    @Published var syncOnWifiOnly: Bool = true
    @Published var offlineDataRadius: Double = 5.0 // km

    // Current shop detection
    @Published var currentShop: Shop?
    @Published var pendingUploads: Int = 0

    private let defaults = UserDefaults.standard

    init() {
        loadSettings()
    }

    func loadSettings() {
        isAuthenticated = defaults.bool(forKey: "isAuthenticated")
        syncOnWifiOnly = defaults.bool(forKey: "syncOnWifiOnly")
        offlineDataRadius = defaults.double(forKey: "offlineDataRadius")
        if offlineDataRadius == 0 { offlineDataRadius = 5.0 }
    }

    func saveSettings() {
        defaults.set(isAuthenticated, forKey: "isAuthenticated")
        defaults.set(syncOnWifiOnly, forKey: "syncOnWifiOnly")
        defaults.set(offlineDataRadius, forKey: "offlineDataRadius")
    }

    func logout() {
        isAuthenticated = false
        currentUser = nil
        userStatus = .waitlist
        saveSettings()
    }
}

enum UserStatus: String, Codable {
    case waitlist
    case active
    case member // NGO member with shopping list access
}
