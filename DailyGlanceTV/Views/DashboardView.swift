import SwiftUI
import UIKit

struct DashboardView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var weatherService = WeatherService()
    @StateObject private var newsService = NewsService()
    @StateObject private var musicPlayer = MusicPlayerService()
    @StateObject private var wordOfDayService = WordOfDayService()

    @State private var currentDate = Date()
    @State private var awakeSince = Date()

    /// Keep the screen awake for a full day of continuous display, then
    /// let tvOS sleep/screensave normally rather than staying on forever.
    private let maxAwakeDuration: TimeInterval = 24 * 60 * 60

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
                    .padding(.top, 14)

                WordOfDayView(wordOfDay: wordOfDayService.wordOfDay)
                    .padding(.top, 8)

                // Left: weather (top) + calendar (bottom). Right: news stack.
                HStack(alignment: .top, spacing: 32) {
                    VStack(alignment: .leading, spacing: 12) {
                        WeatherCardView(snapshot: weatherService.snapshot, errorMessage: weatherService.errorMessage)
                        CalendarGridView(date: currentDate)
                    }
                    .frame(width: 420)

                    NewsStackView(headlines: newsService.headlines)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.top, 14)
                .frame(maxHeight: .infinity)

                HStack {
                    Spacer()
                    MusicWidgetView(
                        stationName: musicPlayer.stationName,
                        stationSource: musicPlayer.stationSource,
                        isPlaying: musicPlayer.isPlaying,
                        onToggle: { musicPlayer.toggle() }
                    )
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 64)
            .padding(.vertical, 16)
        }
        .onReceive(clockTimer) { date in
            currentDate = date
            wordOfDayService.pick(for: date)
            if UIApplication.shared.isIdleTimerDisabled,
               date.timeIntervalSince(awakeSince) > maxAwakeDuration {
                UIApplication.shared.isIdleTimerDisabled = false
            }
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
        .onAppear {
            awakeSince = Date()
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .task {
            locationService.requestLocation()
            musicPlayer.start()
            wordOfDayService.load()
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
