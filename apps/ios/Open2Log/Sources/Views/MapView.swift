import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var appState: AppState
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 61.4978, longitude: 23.7610), // Tampere
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedShop: Shop?
    @State private var showShopConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: locationManager.nearbyShops) { shop in
                    MapAnnotation(coordinate: shop.coordinate) {
                        ShopMarker(shop: shop, isSelected: selectedShop?.id == shop.id)
                            .onTapGesture {
                                selectedShop = shop
                            }
                    }
                }
                .ignoresSafeArea(edges: .top)

                VStack {
                    Spacer()

                    if let shop = selectedShop {
                        ShopDetailCard(shop: shop, userLocation: locationManager.currentLocation)
                            .padding()
                    }
                }
            }
            .navigationTitle("Nearby Shops")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        centerOnUser()
                    } label: {
                        Image(systemName: "location")
                    }
                }
            }
            .onAppear {
                locationManager.requestAuthorization()
            }
            .onChange(of: locationManager.currentLocation) { _, location in
                if let location = location {
                    region.center = location.coordinate
                }
            }
            .onChange(of: locationManager.detectedShop) { _, shop in
                if let shop = shop {
                    selectedShop = shop
                    showShopConfirmation = true
                }
            }
            .alert("Are you at \(locationManager.detectedShop?.name ?? "")?", isPresented: $showShopConfirmation) {
                Button("Yes") {
                    appState.currentShop = locationManager.detectedShop
                }
                Button("No", role: .cancel) {}
            } message: {
                Text("Confirm your location to start scanning prices")
            }
        }
    }

    private func centerOnUser() {
        if let location = locationManager.currentLocation {
            withAnimation {
                region.center = location.coordinate
            }
        }
    }
}

struct ShopMarker: View {
    let shop: Shop
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "cart.fill")
                .font(.title2)
                .foregroundStyle(colorForChain(shop.chain))
                .padding(8)
                .background(
                    Circle()
                        .fill(.white)
                        .shadow(radius: isSelected ? 4 : 2)
                )
                .scaleEffect(isSelected ? 1.2 : 1.0)

            Image(systemName: "triangle.fill")
                .font(.caption2)
                .foregroundStyle(.white)
                .offset(y: -3)
        }
        .animation(.spring(duration: 0.2), value: isSelected)
    }

    private func colorForChain(_ chain: ShopChain) -> Color {
        switch chain {
        case .lidl: return .blue
        case .sKaupat: return .green
        case .kMarket: return .orange
        case .tokmanni: return .red
        case .prisma: return .purple
        case .other: return .gray
        }
    }
}

struct ShopDetailCard: View {
    let shop: Shop
    let userLocation: CLLocation?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(shop.name)
                    .font(.headline)

                Spacer()

                Text(shop.chain.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }

            Text(shop.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let location = userLocation {
                HStack(spacing: 16) {
                    distanceView(distance: shop.distance(from: location))

                    // Travel time estimates would come from Valhalla routing
                    travelTimeView(mode: "figure.walk", time: estimateWalkTime(shop.distance(from: location)))
                    travelTimeView(mode: "bicycle", time: estimateBikeTime(shop.distance(from: location)))
                    travelTimeView(mode: "car", time: estimateDriveTime(shop.distance(from: location)))
                }
            }

            HStack {
                NavigationLink(destination: ShopProductsView(shop: shop)) {
                    Label("Products", systemImage: "list.bullet")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    openInMaps()
                } label: {
                    Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func distanceView(distance: CLLocationDistance) -> some View {
        VStack {
            Text(formatDistance(distance))
                .font(.headline)
            Text("away")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func travelTimeView(mode: String, time: String) -> some View {
        VStack {
            Image(systemName: mode)
                .font(.caption)
            Text(time)
                .font(.caption2)
        }
        .foregroundStyle(.secondary)
    }

    private func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }

    // Simple estimates - real values would come from Valhalla routing
    private func estimateWalkTime(_ distance: CLLocationDistance) -> String {
        let minutes = Int(distance / 80) // ~5 km/h walking speed
        return "\(minutes) min"
    }

    private func estimateBikeTime(_ distance: CLLocationDistance) -> String {
        let minutes = Int(distance / 250) // ~15 km/h cycling speed
        return "\(minutes) min"
    }

    private func estimateDriveTime(_ distance: CLLocationDistance) -> String {
        let minutes = Int(distance / 500) // ~30 km/h average city driving
        return "\(minutes) min"
    }

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: shop.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = shop.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
}

// Placeholder views
struct ShopProductsView: View {
    let shop: Shop
    var body: some View {
        Text("Products at \(shop.name)")
    }
}

struct SearchView: View {
    var body: some View {
        NavigationStack {
            Text("Search Products")
                .navigationTitle("Search")
        }
    }
}

struct ShoppingListView: View {
    var body: some View {
        NavigationStack {
            Text("Shopping Lists (NGO Members Only)")
                .navigationTitle("Lists")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section("Sync") {
                    Toggle("Sync only on WiFi", isOn: $appState.syncOnWifiOnly)

                    Stepper("Offline data radius: \(Int(appState.offlineDataRadius)) km",
                            value: $appState.offlineDataRadius, in: 1...50)
                }

                Section("Account") {
                    if let user = appState.currentUser {
                        Text(user.email)
                        Text("Status: \(appState.userStatus.rawValue.capitalized)")
                    }

                    Button("Log Out", role: .destructive) {
                        appState.logout()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.blue)

            Text("Open2Log")
                .font(.largeTitle)
                .bold()

            Text("Track grocery prices and find the best deals near you")
                .multilineTextAlignment(.center)
                .padding()

            Button("Get Started") {
                appState.isOnboarded = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

struct AuthView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textContentType(isRegistering ? .newPassword : .password)

                Button(isRegistering ? "Sign Up" : "Log In") {
                    // Auth logic here
                }
                .buttonStyle(.borderedProminent)

                Button(isRegistering ? "Already have an account?" : "Create an account") {
                    isRegistering.toggle()
                }
            }
            .navigationTitle(isRegistering ? "Sign Up" : "Log In")
        }
    }
}
