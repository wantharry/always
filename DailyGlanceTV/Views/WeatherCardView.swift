import SwiftUI

struct WeatherCardView: View {
    let snapshot: WeatherSnapshot?
    let errorMessage: String?

    var body: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("WEATHER")
                    .font(.system(size: 16, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))

                if let snapshot {
                    HStack(spacing: 16) {
                        Image(systemName: snapshot.symbolName)
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                            .symbolRenderingMode(.multicolor)

                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(snapshot.temperature)°")
                                .font(DashboardTheme.displayFont(size: 48))
                                .foregroundStyle(.white)
                            Text(snapshot.condition)
                                .font(.system(size: 19, weight: .medium))
                                .foregroundStyle(.white.opacity(0.75))
                        }
                    }

                    HStack(spacing: 16) {
                        Label("\(snapshot.highToday)°", systemImage: "arrow.up")
                            .foregroundStyle(.white.opacity(0.7))
                        Label("\(snapshot.lowToday)°", systemImage: "arrow.down")
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                    }
                    .font(.system(size: 18, weight: .semibold))

                    Divider().overlay(Color.white.opacity(0.12))

                    HStack(spacing: 16) {
                        Label(snapshot.sunrise, systemImage: "sunrise.fill")
                            .foregroundStyle(.white.opacity(0.65))
                        Label(snapshot.sunset, systemImage: "sunset.fill")
                            .foregroundStyle(.white.opacity(0.65))
                    }
                    .font(.system(size: 16, weight: .medium))

                    if let aqi = snapshot.aqi {
                        Label("AQI \(aqi) · \(snapshot.aqiLabel)", systemImage: "aqi.medium")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.65))
                    }

                    Text(snapshot.locationName)
                        .font(.system(size: 17))
                        .foregroundStyle(.white.opacity(0.5))
                } else {
                    Text(errorMessage ?? "Loading weather…")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(20)
            .frame(width: 420, alignment: .leading)
        }
    }
}
