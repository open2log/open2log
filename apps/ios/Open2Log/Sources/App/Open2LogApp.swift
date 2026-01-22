import SwiftUI

@main
struct Open2LogApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var syncManager = SyncManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(locationManager)
                .environmentObject(syncManager)
        }
    }
}
