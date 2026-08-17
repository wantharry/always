import Foundation
import CoreLocation

@MainActor
final class WeatherService: ObservableObject {
    @Published private(set) var snapshot: WeatherSnapshot?
    @Published private(set) var errorMessage: String?

    func refresh(coordinate: CLLocationCoordinate2D, locationName: String) async {
        async let forecast = fetchForecast(coordinate: coordinate)
        async let aqi = fetchAirQuality(coordinate: coordinate)

        guard let forecast = await forecast else {
            errorMessage = "Weather unavailable"
            return
        }
        let aqiValue = await aqi

        let described = WeatherCode.describe(forecast.current.weatherCode)
        snapshot = WeatherSnapshot(
            temperature: Int(forecast.current.temperature.rounded()),
            feelsLike: Int(forecast.current.apparentTemperature.rounded()),
            condition: described.condition,
            symbolName: described.symbol,
            highToday: Int((forecast.daily.tempMax.first ?? forecast.current.temperature).rounded()),
            lowToday: Int((forecast.daily.tempMin.first ?? forecast.current.temperature).rounded()),
            locationName: locationName,
            sunrise: Self.formatTime(forecast.daily.sunrise.first),
            sunset: Self.formatTime(forecast.daily.sunset.first),
            aqi: aqiValue,
            aqiLabel: aqiValue.map(AirQuality.label(for:)) ?? "—"
        )
        errorMessage = nil
    }

    private func fetchForecast(coordinate: CLLocationCoordinate2D) async -> OpenMeteoResponse? {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,weather_code"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,weather_code,sunrise,sunset"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "1"),
        ]
        guard let url = components.url else { return nil }
        return try? JSONDecoder().decode(OpenMeteoResponse.self, from: try await URLSession.shared.data(from: url).0)
    }

    private func fetchAirQuality(coordinate: CLLocationCoordinate2D) async -> Int? {
        var components = URLComponents(string: "https://air-quality-api.open-meteo.com/v1/air-quality")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "current", value: "us_aqi"),
            URLQueryItem(name: "timezone", value: "auto"),
        ]
        guard let url = components.url,
              let data = try? await URLSession.shared.data(from: url).0,
              let response = try? JSONDecoder().decode(AirQualityResponse.self, from: data) else { return nil }
        return response.current.usAqi.map { Int($0.rounded()) }
    }

    private static func formatTime(_ isoString: String?) -> String {
        guard let isoString else { return "—" }
        // Open-Meteo returns local (timezone=auto) times like "2026-08-17T06:32".
        let parts = isoString.split(separator: "T")
        guard parts.count == 2 else { return "—" }
        let timeParts = parts[1].split(separator: ":")
        guard timeParts.count >= 2,
              let hour24 = Int(timeParts[0]),
              let minute = Int(timeParts[1]) else { return "—" }
        let period = hour24 < 12 ? "AM" : "PM"
        var hour12 = hour24 % 12
        if hour12 == 0 { hour12 = 12 }
        return String(format: "%d:%02d %@", hour12, minute, period)
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
        let sunrise: [String]
        let sunset: [String]

        enum CodingKeys: String, CodingKey {
            case tempMax = "temperature_2m_max"
            case tempMin = "temperature_2m_min"
            case sunrise
            case sunset
        }
    }

    let current: Current
    let daily: Daily
}

private struct AirQualityResponse: Decodable {
    struct Current: Decodable {
        let usAqi: Double?

        enum CodingKeys: String, CodingKey {
            case usAqi = "us_aqi"
        }
    }

    let current: Current
}
