import SwiftUI

struct ClockView: View {
    let date: Date

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        return formatter.string(from: date)
    }

    private var periodString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter.string(from: date)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 14) {
                Text(timeString)
                    .font(DashboardTheme.displayFont(size: 188))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                Text(periodString.uppercased())
                    .font(DashboardTheme.displayFontMedium(size: 36))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 38)
            }
            Text(dateString)
                .font(DashboardTheme.displayFontMedium(size: 38))
                .foregroundStyle(.white.opacity(0.88))
        }
        .shadow(color: .black.opacity(0.25), radius: 20, y: 8)
    }
}
