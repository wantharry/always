import Foundation
import CoreLocation

@MainActor
final class WeatherService: ObservableObject {
    @Published private(set) var snapshot: WeatherSnapshot?
    @Published private(set) var errorMessage: String?

    func refresh(coordinate: CLLocationCoordinate2D, locationName: String) async {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,weather_code"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,weather_code"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "1"),
        ]

        guard let url = components.url else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            let described = WeatherCode.describe(response.current.weatherCode)
            snapshot = WeatherSnapshot(
                temperature: Int(response.current.temperature.rounded()),
                feelsLike: Int(response.current.apparentTemperature.rounded()),
                condition: described.condition,
                symbolName: described.symbol,
                highToday: Int((response.daily.tempMax.first ?? response.current.temperature).rounded()),
                lowToday: Int((response.daily.tempMin.first ?? response.current.temperature).rounded()),
                locationName: locationName
            )
            errorMessage = nil
        } catch {
            errorMessage = "Weather unavailable"
        }
    }
}

private struct OpenMeteoResponse: Decodable {
    struct Current: Decodable {
        let temperature: Double
        let apparentTemperature: Double
        let weatherCode: Int

        enum CodingKeys: String, CodingKey {
            case temperature = "temperature_2m"
            case apparentTemperature = "apparent_temperature"
            case weatherCode = "weather_code"
        }
    }

    struct Daily: Decodable {
        let tempMax: [Double]
        let tempMin: [Double]

        enum CodingKeys: String, CodingKey {
            case tempMax = "temperature_2m_max"
            case tempMin = "temperature_2m_min"
        }
    }

    let current: Current
    let daily: Daily
}
