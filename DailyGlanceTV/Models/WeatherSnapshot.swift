import Foundation

struct WeatherSnapshot {
    let temperature: Int
    let feelsLike: Int
    let condition: String
    let symbolName: String
    let highToday: Int
    let lowToday: Int
    let locationName: String
    let sunrise: String
    let sunset: String
    let aqi: Int?
    let aqiLabel: String
}

/// Maps WMO weather codes (used by Open-Meteo) to a label + SF Symbol.
enum WeatherCode {
    static func describe(_ code: Int) -> (condition: String, symbol: String) {
        switch code {
        case 0: return ("Clear Sky", "sun.max.fill")
        case 1: return ("Mostly Clear", "sun.max.fill")
        case 2: return ("Partly Cloudy", "cloud.sun.fill")
        case 3: return ("Overcast", "cloud.fill")
        case 45, 48: return ("Foggy", "cloud.fog.fill")
        case 51, 53, 55: return ("Drizzle", "cloud.drizzle.fill")
        case 56, 57: return ("Freezing Drizzle", "cloud.sleet.fill")
        case 61, 63, 65: return ("Rain", "cloud.rain.fill")
        case 66, 67: return ("Freezing Rain", "cloud.sleet.fill")
        case 71, 73, 75: return ("Snow", "cloud.snow.fill")
        case 77: return ("Snow Grains", "cloud.snow.fill")
        case 80, 81, 82: return ("Rain Showers", "cloud.heavyrain.fill")
        case 85, 86: return ("Snow Showers", "cloud.snow.fill")
        case 95: return ("Thunderstorm", "cloud.bolt.fill")
        case 96, 99: return ("Thunderstorm & Hail", "cloud.bolt.rain.fill")
        default: return ("Unknown", "questionmark.circle.fill")
        }
    }
}

/// Maps the US AQI scale to a short label.
enum AirQuality {
    static func label(for aqi: Int) -> String {
        switch aqi {
        case ..<51: return "Good"
        case 51..<101: return "Moderate"
        case 101..<151: return "Unhealthy (Sensitive)"
        case 151..<201: return "Unhealthy"
        case 201..<301: return "Very Unhealthy"
        default: return "Hazardous"
        }
    }
}
