import SwiftUI

struct NewsTickerView: View {
    let headlines: [NewsHeadline]
    @State private var index = 0

    private let timer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()

    var body: some View {
        DashboardCard(cornerRadius: 20) {
            HStack(spacing: 16) {
                Label("BBC NEWS", systemImage: "newspaper.fill")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize()

                if headlines.isEmpty {
                    Text("Loading headlines…")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                } else {
                    Text(headlines[index % headlines.count].title)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .id(index % headlines.count)
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 18)
        }
        .onReceive(timer) { _ in
            guard !headlines.isEmpty else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                index += 1
            }
        }
    }
}
