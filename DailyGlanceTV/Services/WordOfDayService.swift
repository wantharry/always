import Foundation
import SwiftUI

@MainActor
final class WordOfDayService: ObservableObject {
    @Published private(set) var wordOfDay: WordOfDay?

    private var words: [VocabWord] = []

    func load() {
        guard words.isEmpty,
              let url = Bundle.main.url(forResource: "words", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([VocabWord].self, from: data),
              !decoded.isEmpty else { return }
        words = decoded
        pick(for: Date())
    }

    /// Deterministic pick so the same word shows all day and changes at
    /// midnight, without needing a stored "last shown" date.
    func pick(for date: Date) {
        guard !words.isEmpty else { return }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let year = calendar.component(.year, from: date)
        let index = (year * 1000 + dayOfYear) % words.count
        let selected = words[index]
        if wordOfDay?.word != selected.word {
            wordOfDay = WordOfDay(word: selected.word.capitalized, meaning: selected.meaning)
        }
    }
}
