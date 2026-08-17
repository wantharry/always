import Foundation

struct NewsHeadline: Identifiable, Equatable {
    let title: String

    /// Stable across refreshes (derived from the title) so SwiftUI only
    /// animates genuinely new headlines instead of re-animating the whole list.
    var id: String { title }
}
