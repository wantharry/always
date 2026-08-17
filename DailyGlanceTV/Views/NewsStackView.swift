import SwiftUI

struct NewsStackView: View {
    let headlines: [NewsHeadline]

    private var topFive: [NewsHeadline] {
        Array(headlines.prefix(5))
    }

    var body: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("NPR NEWS", systemImage: "newspaper.fill")
                    .font(.system(size: 15, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))

                if topFive.isEmpty {
                    Text("Loading headlines…")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.6))
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(topFive) { headline in
                            Text(headline.title)
                                .font(.system(size: 21, weight: .medium))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .id(headline.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .opacity
                                ))

                            if headline.id != topFive.last?.id {
                                Divider().overlay(Color.white.opacity(0.12))
                            }
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(26)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
