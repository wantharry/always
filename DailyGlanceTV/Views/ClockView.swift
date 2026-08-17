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
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Text(timeString)
                    .font(.system(size: 148, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                Text(periodString.uppercased())
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 30)
            }
            Text(dateString)
                .font(.system(size: 32, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
        }
        .shadow(color: .black.opacity(0.25), radius: 20, y: 8)
    }
}
