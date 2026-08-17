import SwiftUI

struct CalendarGridView: View {
    let date: Date

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        return cal
    }()

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private var holidays: [Holiday] {
        HolidayService.holidays(for: calendar.component(.year, from: date))
    }

    private var nextHoliday: Holiday? {
        let year = calendar.component(.year, from: date)
        let all = HolidayService.holidays(for: year) + HolidayService.holidays(for: year + 1)
        return all
            .compactMap { holiday -> (Holiday, Int)? in
                var comps = DateComponents()
                comps.year = holiday.year ?? year
                comps.month = holiday.month
                comps.day = holiday.day
                guard let holidayDate = calendar.date(from: comps) else { return nil }
                let days = calendar.dateComponents([.day], from: date, to: holidayDate).day ?? -1
                return days >= 0 ? (holiday, days) : nil
            }
            .min(by: { $0.1 < $1.1 })?.0
    }

    private var weeks: [[Int?]] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) // 1 = Sunday
        var cells: [Int?] = Array(repeating: nil, count: firstWeekday - 1)
        cells.append(contentsOf: range.map { $0 })
        while cells.count % 7 != 0 { cells.append(nil) }
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0 + 7]) }
    }

    private func holidaysOn(day: Int) -> [Holiday] {
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return holidays.filter { $0.matches(month: month, day: day, year: year) }
    }

    private var today: Int { calendar.component(.day, from: date) }

    private var moonPhase: MoonPhase { MoonPhase.compute(for: date) }

    var body: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(monthTitle.uppercased())
                    .font(.system(size: 17, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.55))

                // Fixed total height regardless of whether the month spans
                // 5 or 6 weeks -- rows divide the same budget evenly so the
                // card never grows and pushes the rest of the screen off
                // the bottom edge.
                GeometryReader { grid in
                    let rowHeight = grid.size.height / CGFloat(weeks.count + 1)
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .frame(width: grid.size.width / 7, height: rowHeight)
                            }
                        }
                        ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                            HStack(spacing: 0) {
                                ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                                    dayCell(day)
                                        .frame(width: grid.size.width / 7, height: rowHeight)
                                }
                            }
                        }
                    }
                }
                .frame(height: 200)

                if let next = nextHoliday {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(red: next.country.color.red, green: next.country.color.green, blue: next.country.color.blue))
                            .frame(width: 8, height: 8)
                        Text("\(next.name) · \(next.country.label)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: moonPhase.symbolName)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("\(moonPhase.name) · \(moonPhase.illumination)%")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .padding(20)
            .frame(width: 420, alignment: .leading)
        }
    }

    @ViewBuilder
    private func dayCell(_ day: Int?) -> some View {
        if let day {
            let dayHolidays = holidaysOn(day: day)
            let isToday = day == today
            VStack(spacing: 1) {
                Text("\(day)")
                    .font(.system(size: 13, weight: isToday ? .bold : .regular))
                    .foregroundStyle(isToday ? Color(red: 0.15, green: 0.12, blue: 0.32) : .white.opacity(0.85))
                    .frame(width: 22, height: 22)
                    .background(isToday ? Circle().fill(Color.white.opacity(0.9)) : nil)

                if let first = dayHolidays.first {
                    Circle()
                        .fill(Color(red: first.country.color.red, green: first.country.color.green, blue: first.country.color.blue))
                        .frame(width: 4, height: 4)
                } else {
                    Color.clear.frame(width: 4, height: 4)
                }
            }
        } else {
            Color.clear
        }
    }
}
