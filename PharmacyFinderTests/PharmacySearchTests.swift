import MapKit
import Testing
@testable import PharmacyFinder

struct PharmacySearchTests {
    @Test func sortsPharmaciesNearestFirst() {
        let user = CLLocation(latitude: 60.1699, longitude: 24.9384) // Helsinki centre
        let far = mapItem("Far", latitude: 60.1800, longitude: 24.9400)
        let near = mapItem("Near", latitude: 60.1705, longitude: 24.9384)

        let result = PharmacySearch.sortedByDistance([far, near], from: user)

        #expect(result.map(\.name) == ["Near", "Far"])
        #expect(result[0].distance < 100)
    }

    private func mapItem(_ name: String, latitude: Double, longitude: Double) -> MKMapItem {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
        item.name = name
        return item
    }
}
