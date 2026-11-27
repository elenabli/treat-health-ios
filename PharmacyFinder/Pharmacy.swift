import MapKit

struct Pharmacy: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
    let distance: CLLocationDistance // metres from the user

    var name: String { mapItem.name ?? "Pharmacy" }
    var coordinate: CLLocationCoordinate2D { mapItem.placemark.coordinate }

    /// Street and house number, e.g. "Mannerheimintie 1".
    var address: String? {
        let placemark = mapItem.placemark
        guard let street = placemark.thoroughfare else { return nil }
        return [street, placemark.subThoroughfare].compactMap { $0 }.joined(separator: " ")
    }
}

enum PharmacySearch {
    /// Finds pharmacies within `radius` metres of `location`, nearest first, using Apple Maps data.
    static func nearby(_ location: CLLocation, radius: CLLocationDistance = 5000) async throws -> [Pharmacy] {
        let request = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: radius)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.pharmacy])

        let response = try await MKLocalSearch(request: request).start()
        return sortedByDistance(response.mapItems, from: location)
    }

    static func sortedByDistance(_ items: [MKMapItem], from location: CLLocation) -> [Pharmacy] {
        items
            .map { item in
                let itemLocation = CLLocation(latitude: item.placemark.coordinate.latitude,
                                              longitude: item.placemark.coordinate.longitude)
                return Pharmacy(mapItem: item, distance: itemLocation.distance(from: location))
            }
            .sorted { $0.distance < $1.distance }
    }
}
