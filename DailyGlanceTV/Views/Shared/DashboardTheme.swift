import SwiftUI

enum DashboardTheme {
    /// Returns a gradient that shifts subtly with the time of day. Always
    /// dark/low-luminance so the app is safe to leave on a TV continuously
    /// (no bright daytime mode, no OLED burn-in risk).
    static func gradient(for date: Date) -> [Color] {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<8:   // dawn - dark navy into muted maroon
            return [Color(red: 0.07, green: 0.06, blue: 0.14), Color(red: 0.20, green: 0.10, blue: 0.14)]
        case 8..<17:  // day - dark slate blue
            return [Color(red: 0.04, green: 0.08, blue: 0.16), Color(red: 0.10, green: 0.16, blue: 0.24)]
        case 17..<20: // dusk - dark plum
            return [Color(red: 0.14, green: 0.06, blue: 0.12), Color(red: 0.08, green: 0.05, blue: 0.18)]
        default:      // night - near-black indigo
            return [Color(red: 0.02, green: 0.03, blue: 0.08), Color(red: 0.06, green: 0.05, blue: 0.14)]
        }
    }

    static let cardFill = Color.white.opacity(0.10)
    static let cardBorder = Color.white.opacity(0.18)

    /// Display font for hero elements (clock, big numbers). Falls back to
    /// the system rounded font automatically if unavailable.
    static func displayFont(size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        .custom("AvenirNext-Heavy", size: size)
    }

    static func displayFontMedium(size: CGFloat) -> Font {
        .custom("AvenirNext-DemiBold", size: size)
    }
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
