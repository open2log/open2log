import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.isOnboarded {
                OnboardingView()
            } else if !appState.isAuthenticated {
                AuthView()
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(0)

            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }
                .tag(1)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)

            if appState.userStatus == .member {
                ShoppingListView()
                    .tabItem {
                        Label("Lists", systemImage: "list.bullet")
                    }
                    .tag(3)
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}
