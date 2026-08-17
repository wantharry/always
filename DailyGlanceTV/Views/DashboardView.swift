import SwiftUI

struct DashboardView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var weatherService = WeatherService()
    @StateObject private var newsService = NewsService()
    @StateObject private var musicPlayer = MusicPlayerService()

    @State private var currentDate = Date()

    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let weatherRefreshTimer = Timer.publish(every: 20 * 60, on: .main, in: .common).autoconnect()
    private let newsRefreshTimer = Timer.publish(every: 10 * 60, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            DashboardBackground(date: currentDate)

            VStack(spacing: 0) {
                // Top center: clock + date
                ClockView(date: currentDate)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 56)

                // Left: weather (top) + calendar (bottom). Right: news stack.
                HStack(alignment: .top, spacing: 32) {
                    VStack(alignment: .leading, spacing: 28) {
                        WeatherCardView(snapshot: weatherService.snapshot, errorMessage: weatherService.errorMessage)
                        CalendarGridView(date: currentDate)
                        Spacer(minLength: 0)
                    }
                    .frame(width: 360)

                    NewsStackView(headlines: newsService.headlines)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.top, 44)

                HStack {
                    Spacer()
                    MusicWidgetView(
                        stationName: musicPlayer.stationName,
                        stationSource: musicPlayer.stationSource,
                        isPlaying: musicPlayer.isPlaying,
                        onToggle: { musicPlayer.toggle() }
                    )
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 64)
            .padding(.bottom, 48)
        }
        .onReceive(clockTimer) { date in
            currentDate = date
        }
        .onReceive(weatherRefreshTimer) { _ in
            Task { await refreshWeather() }
        }
        .onReceive(newsRefreshTimer) { _ in
            Task { await newsService.refresh() }
        }
        .onChange(of: locationService.isUsingFallback) { _, _ in
            Task { await refreshWeather() }
        }
        .task {
            locationService.requestLocation()
            musicPlayer.start()
            await refreshWeather()
            await newsService.refresh()
        }
    }

    private func refreshWeather() async {
        await weatherService.refresh(
            coordinate: locationService.coordinate,
            locationName: locationService.locationName
        )
    }
}
