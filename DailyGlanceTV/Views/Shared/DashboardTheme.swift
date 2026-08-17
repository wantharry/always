import SwiftUI

enum DashboardTheme {
    /// Returns a gradient that shifts with the time of day.
    static func gradient(for date: Date) -> [Color] {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<8:   // dawn
            return [Color(red: 0.98, green: 0.62, blue: 0.42), Color(red: 0.55, green: 0.35, blue: 0.55)]
        case 8..<17:  // day
            return [Color(red: 0.30, green: 0.55, blue: 0.85), Color(red: 0.55, green: 0.75, blue: 0.92)]
        case 17..<20: // dusk
            return [Color(red: 0.95, green: 0.45, blue: 0.35), Color(red: 0.35, green: 0.22, blue: 0.55)]
        default:      // night
            return [Color(red: 0.05, green: 0.07, blue: 0.18), Color(red: 0.15, green: 0.12, blue: 0.32)]
        }
    }

    static let cardFill = Color.white.opacity(0.10)
    static let cardBorder = Color.white.opacity(0.18)
}

struct DashboardBackground: View {
    let date: Date

    var body: some View {
        LinearGradient(
            colors: DashboardTheme.gradient(for: date),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .animation(.easeInOut(duration: 2), value: Calendar.current.component(.hour, from: date))
        .ignoresSafeArea()
    }
}

struct DashboardCard<Content: View>: View {
    var cornerRadius: CGFloat = 26
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DashboardTheme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DashboardTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
