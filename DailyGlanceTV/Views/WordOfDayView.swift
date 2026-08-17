import SwiftUI

struct WordOfDayView: View {
    let wordOfDay: WordOfDay?

    var body: some View {
        DashboardCard {
            HStack(alignment: .top, spacing: 20) {
                Image(systemName: "text.book.closed.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text("WORD OF THE DAY")
                        .font(.system(size: 15, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.5))

                    if let wordOfDay {
                        HStack(alignment: .firstTextBaseline, spacing: 14) {
                            Text(wordOfDay.word)
                                .font(DashboardTheme.displayFontMedium(size: 30))
                                .foregroundStyle(.white)
                            Text(wordOfDay.meaning)
                                .font(.system(size: 20))
                                .foregroundStyle(.white.opacity(0.7))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    } else {
                        Text("Loading…")
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
    }
}
