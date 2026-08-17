import Foundation
import CoreLocation

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    /// Jacksonville, FL - used until real location is available or if
    /// permission is denied (tvOS location is approximate/WiFi-based).
    static let fallback = CLLocationCoordinate2D(latitude: 30.3322, longitude: -81.6557)
    static let fallbackName = "Jacksonville, FL"

    @Published private(set) var coordinate: CLLocationCoordinate2D
    @Published private(set) var locationName: String
    @Published private(set) var isUsingFallback = true

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        coordinate = Self.fallback
        locationName = Self.fallbackName
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
    }

    func requestLocation() {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            coordinate = location.coordinate
            isUsingFallback = false
            await reverseGeocode(location)
        }
    }

    private func reverseGeocode(_ location: CLLocation) async {
        guard let placemarks = try? await geocoder.reverseGeocodeLocation(location),
              let placemark = placemarks.first else { return }
        let city = placemark.locality ?? placemark.name
        let state = placemark.administrativeArea
        switch (city, state) {
        case let (city?, state?): locationName = "\(city), \(state)"
        case let (city?, nil): locationName = city
        default: break
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Keep using the fallback coordinate.
    }
}
