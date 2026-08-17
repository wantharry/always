import Foundation

enum HolidayCountry {
    case usa
    case india
    case both

    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .usa: return (0.36, 0.58, 0.98)      // blue
        case .india: return (1.0, 0.58, 0.0)      // saffron
        case .both: return (0.7, 0.5, 0.95)       // blended purple
        }
    }

    var label: String {
        switch self {
        case .usa: return "US"
        case .india: return "IN"
        case .both: return "US/IN"
        }
    }
}

struct Holiday: Identifiable {
    let id = UUID()
    let name: String
    let country: HolidayCountry
    let month: Int
    let day: Int
    let year: Int?

    /// True if this holiday falls on the given date (year-agnostic for fixed
    /// annual holidays, year-specific for movable/lunar holidays).
    func matches(month: Int, day: Int, year: Int) -> Bool {
        guard self.month == month, self.day == day else { return false }
        if let fixedYear = self.year {
            return fixedYear == year
        }
        return true
    }
}
