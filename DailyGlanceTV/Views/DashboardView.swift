import SwiftUI
import UIKit

private struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct DashboardView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var weatherService = WeatherService()
    @StateObject private var newsService = NewsService()
    @StateObject private var musicPlayer = MusicPlayerService()
    @StateObject private var wordOfDayService = WordOfDayService()

    @State private var currentDate = Date()
    @State private var contentHeight: CGFloat = 0
    @State private var awakeSince = Date()

    /// Keep the screen awake for a full day of continuous display, then
    /// let tvOS sleep/screensave normally rather than staying on forever.
    private let maxAwakeDuration: TimeInterval = 24 * 60 * 60

    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let weatherRefreshTimer = Timer.publish(every: 20 * 60, on: .main, in: .common).autoconnect()
    private let newsRefreshTimer = Timer.publish(every: 10 * 60, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { screen in
            ZStack {
                DashboardBackground(date: currentDate)

                VStack(spacing: 0) {
                    // Top center: clock + date
                    ClockView(date: currentDate)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 56)

                    WordOfDayView(wordOfDay: wordOfDayService.wordOfDay)
                        .padding(.top, 24)

                    // Left: weather (top) + calendar (bottom). Right: news stack.
                    HStack(alignment: .top, spacing: 32) {
                        VStack(alignment: .leading, spacing: 28) {
                            WeatherCardView(snapshot: weatherService.snapshot, errorMessage: weatherService.errorMessage)
                            CalendarGridView(date: currentDate)
                        }
                        .frame(width: 400)

                        NewsStackView(headlines: newsService.headlines)
                            .frame(maxWidth: .infinity)
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
                .background(
                    GeometryReader { content in
                        Color.clear.preference(key: ContentHeightKey.self, value: content.size.height)
                    }
                )
                // Whatever combination of variable-height content shows up
                // (5- vs 6-week months, holiday line present or not, news
                // headline count), scale the whole dashboard down just
                // enough to stay on-screen instead of running off the
                // bottom edge. Never scales up past 1.
                .scaleEffect(scaleToFit(in: screen.size.height), anchor: .top)
                .frame(width: screen.size.width, height: screen.size.height, alignment: .top)
            }
            .onPreferenceChange(ContentHeightKey.self) { contentHeight = $0 }
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

    private func scaleToFit(in availableHeight: CGFloat) -> CGFloat {
        guard contentHeight > 0, availableHeight > 0, contentHeight > availableHeight else { return 1 }
        return availableHeight / contentHeight
    }

    private func refreshWeather() async {
        await weatherService.refresh(
            coordinate: locationService.coordinate,
            locationName: locationService.locationName
        )
    }
}
