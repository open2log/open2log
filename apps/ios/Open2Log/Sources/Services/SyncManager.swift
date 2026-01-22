import Foundation
import Network
import Combine

/// Manages syncing pending uploads and offline data
class SyncManager: ObservableObject {
    @Published var isOnline: Bool = false
    @Published var isWifi: Bool = false
    @Published var isSyncing: Bool = false
    @Published var pendingCount: Int = 0
    @Published var lastSyncAt: Date?

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "SyncManager")
    private var cancellables = Set<AnyCancellable>()

    private let apiClient: APIClient
    private let imageUploader: ImageUploader

    init(apiClient: APIClient = APIClient(), imageUploader: ImageUploader = ImageUploader()) {
        self.apiClient = apiClient
        self.imageUploader = imageUploader
        setupNetworkMonitoring()
    }

    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                self?.isWifi = path.usesInterfaceType(.wifi)

                // Auto-sync when coming online
                if path.status == .satisfied {
                    self?.attemptSync()
                }
            }
        }
        monitor.start(queue: queue)
    }

    func attemptSync() {
        guard isOnline && !isSyncing else { return }

        // Check wifi-only setting
        let settings = UserDefaults.standard
        let wifiOnly = settings.bool(forKey: "syncOnWifiOnly")
        if wifiOnly && !isWifi {
            return
        }

        Task {
            await performSync()
        }
    }

    @MainActor
    private func performSync() async {
        isSyncing = true
        defer { isSyncing = false }

        // Get pending uploads from SwiftData
        // This would query the local database for PendingUpload items
        // and upload them one by one

        do {
            // 1. Upload pending images first
            // 2. Then upload the price data with image URLs
            // 3. Mark as complete or update retry count

            lastSyncAt = Date()
        } catch {
            print("Sync failed: \(error)")
        }
    }

    func downloadOfflineData(for location: CLLocationCoordinate2D, radiusKm: Double) async throws {
        // Download:
        // 1. Nearby shops
        // 2. Products commonly found in those shops
        // 3. Recent prices
        // 4. Weather data
        // 5. Navigation tiles (Valhalla)

        // Store in local SwiftData/SQLite
    }
}
