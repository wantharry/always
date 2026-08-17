import Foundation

struct MoonPhase {
    let name: String
    let symbolName: String
    let illumination: Int

    /// Pure date-math calculation, no network required. Uses the known new
    /// moon of 2000-01-06 18:14 UTC as a reference point and the mean
    /// synodic month length to find how far into the current lunar cycle
    /// `date` falls.
    static func compute(for date: Date) -> MoonPhase {
        let synodicMonth = 29.530588861
        let referenceNewMoon = Date(timeIntervalSince1970: 947182440) // 2000-01-06 18:14 UTC

        let daysSinceReference = date.timeIntervalSince(referenceNewMoon) / 86400
        var phase = daysSinceReference.truncatingRemainder(dividingBy: synodicMonth) / synodicMonth
        if phase < 0 { phase += 1 }

        let illumination = Int(((1 - cos(2 * Double.pi * phase)) / 2) * 100)

        let (name, symbol): (String, String)
        switch phase {
        case 0..<0.03, 0.97...1: (name, symbol) = ("New Moon", "moonphase.new.moon")
        case 0.03..<0.22: (name, symbol) = ("Waxing Crescent", "moonphase.waxing.crescent")
        case 0.22..<0.28: (name, symbol) = ("First Quarter", "moonphase.first.quarter")
        case 0.28..<0.47: (name, symbol) = ("Waxing Gibbous", "moonphase.waxing.gibbous")
        case 0.47..<0.53: (name, symbol) = ("Full Moon", "moonphase.full.moon")
        case 0.53..<0.72: (name, symbol) = ("Waning Gibbous", "moonphase.waning.gibbous")
        case 0.72..<0.78: (name, symbol) = ("Last Quarter", "moonphase.last.quarter")
        default: (name, symbol) = ("Waning Crescent", "moonphase.waning.crescent")
        }

        return MoonPhase(name: name, symbolName: symbol, illumination: illumination)
    }
}
