import SwiftUI

struct MusicWidgetView: View {
    let stationName: String
    let stationSource: String
    let isPlaying: Bool
    let onToggle: () -> Void

    var body: some View {
        DashboardCard(cornerRadius: 20) {
            Button(action: onToggle) {
                HStack(spacing: 14) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(stationName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(stationSource)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.55))
                    }

                    if isPlaying {
                        MusicWaveform()
                            .frame(width: 20, height: 16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct MusicWaveform: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 3, height: animate ? CGFloat.random(in: 6...16) : 6)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.15),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}
