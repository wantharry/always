import Foundation

enum HolidayService {
    /// Returns the full holiday list for a given year. Fixed-date holidays
    /// (month/day) recur automatically every year. US "nth weekday of month"
    /// holidays (e.g. "3rd Monday of January") are computed. Movable Indian
    /// holidays follow the lunisolar calendar and are hardcoded per-year below
    /// - update `movableIndianHolidays(for:)` when a new year needs adding.
    static func holidays(for year: Int) -> [Holiday] {
        fixedHolidays + computedUSHolidays(for: year) + movableIndianHolidays(for: year)
    }

    private static let fixedHolidays: [Holiday] = [
        Holiday(name: "New Year's Day", country: .both, month: 1, day: 1, year: nil),
        Holiday(name: "Republic Day", country: .india, month: 1, day: 26, year: nil),
        Holiday(name: "Juneteenth", country: .usa, month: 6, day: 19, year: nil),
        Holiday(name: "Independence Day", country: .usa, month: 7, day: 4, year: nil),
        Holiday(name: "Independence Day", country: .india, month: 8, day: 15, year: nil),
        Holiday(name: "Gandhi Jayanti", country: .india, month: 10, day: 2, year: nil),
        Holiday(name: "Veterans Day", country: .usa, month: 11, day: 11, year: nil),
        Holiday(name: "Christmas Day", country: .both, month: 12, day: 25, year: nil),
    ]

    /// US federal holidays defined as the "nth weekday of month" rather than
    /// a fixed date, computed so they land correctly for any year.
    private static func computedUSHolidays(for year: Int) -> [Holiday] {
        var results: [Holiday] = []
        func add(_ name: String, month: Int, weekday: Int, occurrence: Int) {
            if let date = nthWeekday(year: year, month: month, weekday: weekday, occurrence: occurrence) {
                let comps = Calendar.current.dateComponents([.month, .day], from: date)
                results.append(Holiday(name: name, country: .usa, month: comps.month!, day: comps.day!, year: year))
            }
        }
        func addLast(_ name: String, month: Int, weekday: Int) {
            if let date = lastWeekday(year: year, month: month, weekday: weekday) {
                let comps = Calendar.current.dateComponents([.month, .day], from: date)
                results.append(Holiday(name: name, country: .usa, month: comps.month!, day: comps.day!, year: year))
            }
        }

        add("Martin Luther King Jr. Day", month: 1, weekday: 2, occurrence: 3)
        add("Presidents' Day", month: 2, weekday: 2, occurrence: 3)
        addLast("Memorial Day", month: 5, weekday: 2)
        add("Labor Day", month: 9, weekday: 2, occurrence: 1)
        add("Columbus Day", month: 10, weekday: 2, occurrence: 2)
        add("Thanksgiving", month: 11, weekday: 5, occurrence: 4)
        return results
    }

    /// Movable Indian holidays follow the lunisolar calendar; these are
    /// commonly published estimates and should be reviewed/updated yearly.
    private static func movableIndianHolidays(for year: Int) -> [Holiday] {
        switch year {
        case 2026:
            return [
                Holiday(name: "Makar Sankranti", country: .india, month: 1, day: 14, year: 2026),
                Holiday(name: "Holi", country: .india, month: 3, day: 4, year: 2026),
                Holiday(name: "Raksha Bandhan", country: .india, month: 8, day: 28, year: 2026),
                Holiday(name: "Dussehra", country: .india, month: 10, day: 20, year: 2026),
                Holiday(name: "Diwali", country: .india, month: 11, day: 8, year: 2026),
            ]
        default:
            return []
        }
    }

    /// weekday: 1 = Sunday ... 7 = Saturday (matching Calendar.dateComponents)
    private static func nthWeekday(year: Int, month: Int, weekday: Int, occurrence: Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York") ?? .current

        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.weekday = weekday
        comps.weekdayOrdinal = occurrence
        return calendar.date(from: comps)
    }

    private static func lastWeekday(year: Int, month: Int, weekday: Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York") ?? .current

        guard let range = calendar.range(of: .day, in: .month, for: calendar.date(from: DateComponents(year: year, month: month, day: 1))!) else {
            return nil
        }
        for day in stride(from: range.upperBound - 1, through: 1, by: -1) {
            if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)),
               calendar.component(.weekday, from: date) == weekday {
                return date
            }
        }
        return nil
    }
}
