import SwiftUI

struct WeatherCardView: View {
    let snapshot: WeatherSnapshot?
    let errorMessage: String?

    var body: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("WEATHER")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))

                if let snapshot {
                    HStack(spacing: 16) {
                        Image(systemName: snapshot.symbolName)
                            .font(.system(size: 44))
                            .foregroundStyle(.white)
                            .symbolRenderingMode(.multicolor)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(snapshot.temperature)°")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(snapshot.condition)
                                .font(.system(size: 17, weight: .medium))
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
                    .font(.system(size: 16, weight: .semibold))

                    Text(snapshot.locationName)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.5))
                } else {
                    Text(errorMessage ?? "Loading weather…")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(24)
            .frame(width: 320, alignment: .leading)
        }
    }
}
