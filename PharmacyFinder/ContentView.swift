import MapKit
import SwiftUI

struct ContentView: View {
    @State private var pharmacies: [Pharmacy] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searched = false
    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)

    private let locationProvider = LocationProvider()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Map(position: $camera) {
                    UserAnnotation()
                    ForEach(pharmacies) { pharmacy in
                        Marker(pharmacy.name, systemImage: "cross.case.fill", coordinate: pharmacy.coordinate)
                            .tint(pharmacy.id == pharmacies.first?.id ? .green : .gray)
                    }
                }
                .frame(height: 300)

                List {
                    if let errorMessage {
                        Text(errorMessage).foregroundStyle(.red)
                    } else if searched && pharmacies.isEmpty {
                        Text("No pharmacies found within 5 km.")
                    }

                    ForEach(pharmacies) { pharmacy in
                        PharmacyRow(pharmacy: pharmacy, isNearest: pharmacy.id == pharmacies.first?.id)
                    }
                }
            }
            .navigationTitle("Nearest Pharmacy")
            .safeAreaInset(edge: .bottom) {
                Button(action: search) {
                    Text(isLoading ? "Searching…" : "Find the nearest pharmacy")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isLoading)
                .padding()
            }
        }
    }

    private func search() {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                let location = try await locationProvider.currentLocation()
                pharmacies = try await PharmacySearch.nearby(location)
                searched = true
                if let nearest = pharmacies.first {
                    camera = .item(nearest.mapItem)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct PharmacyRow: View {
    let pharmacy: Pharmacy
    let isNearest: Bool

    var body: some View {
        // Tapping a row opens walking directions in Apple Maps.
        Button {
            pharmacy.mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    if isNearest {
                        Text("NEAREST").font(.caption.bold()).foregroundStyle(.green)
                    }
                    Text(pharmacy.name).font(.headline)
                    if let address = pharmacy.address {
                        Text(address).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(Measurement(value: pharmacy.distance, unit: UnitLength.meters),
                     format: .measurement(width: .abbreviated, usage: .road))
                    .foregroundStyle(.secondary)
            }
        }
        .tint(.primary)
    }
}

#Preview {
    ContentView()
}
