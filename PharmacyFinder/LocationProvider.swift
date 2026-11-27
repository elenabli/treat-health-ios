import CoreLocation

enum LocationError: LocalizedError {
    case denied

    var errorDescription: String? {
        "Location access is off. Turn it on in Settings to find pharmacies near you."
    }
}

/// Gets the user's current location once, asking for permission first if needed.
@MainActor
final class LocationProvider: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func currentLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization() // the answer arrives in locationManagerDidChangeAuthorization
            case .denied, .restricted:
                finish(with: .failure(LocationError.denied))
            default:
                manager.requestLocation()
            }
        }
    }

    private func finish(with result: Result<CLLocation, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }

    // MARK: CLLocationManagerDelegate (called on the main thread, where the manager was created)

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated {
            guard continuation != nil else { return }

            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways: manager.requestLocation()
            case .denied, .restricted: finish(with: .failure(LocationError.denied))
            default: break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        MainActor.assumeIsolated {
            if let location = locations.last {
                finish(with: .success(location))
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        MainActor.assumeIsolated {
            finish(with: .failure(error))
        }
    }
}
