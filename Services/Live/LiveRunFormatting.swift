import Foundation

/// Same date/time copy as `RunFormatting`, parameterized directly instead of tied to the mock
/// `Run` type — `LiveRun`/`LiveRunDetail` are a separate model family (see LiveModels.swift).
enum LiveRunFormatting {
    private static func dayFormatter(timeZone: TimeZone) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        f.timeZone = timeZone
        return f
    }

    private static func timeFormatter(timeZone: TimeZone) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.timeZone = timeZone
        return f
    }

    private static func zoneAbbreviation(_ timeZone: TimeZone) -> String {
        timeZone.abbreviation() ?? timeZone.identifier
    }

    static func monthAbbreviation(startsAt: Date, timezoneID: String) -> String {
        let tz = TimeZone(identifier: timezoneID) ?? .current
        let f = DateFormatter()
        f.dateFormat = "MMM"
        f.timeZone = tz
        return f.string(from: startsAt).uppercased()
    }

    static func dayNumber(startsAt: Date, timezoneID: String) -> String {
        let tz = TimeZone(identifier: timezoneID) ?? .current
        let f = DateFormatter()
        f.dateFormat = "d"
        f.timeZone = tz
        return f.string(from: startsAt)
    }

    /// "Sun, Sep 6 · 8:00–10:00 AM · 5v5 full court" — card style.
    static func cardWhen(startsAt: Date, endsAt: Date, timezoneID: String, format: RunFormat) -> String {
        let tz = TimeZone(identifier: timezoneID) ?? .current
        let day = dayFormatter(timeZone: tz).string(from: startsAt)
        let start = timeFormatter(timeZone: tz).string(from: startsAt)
        let end = timeFormatter(timeZone: tz).string(from: endsAt)
        return "\(day) · \(start)–\(end) · \(format.shortLabel)"
    }

    /// "Wed, Sep 9 · 12:00 PM – 1:00 PM PDT · 5v5 full court" — Event Detail heading style.
    static func detailWhen(startsAt: Date, endsAt: Date, timezoneID: String, format: RunFormat) -> String {
        let tz = TimeZone(identifier: timezoneID) ?? .current
        let day = dayFormatter(timeZone: tz).string(from: startsAt)
        let start = timeFormatter(timeZone: tz).string(from: startsAt)
        let end = timeFormatter(timeZone: tz).string(from: endsAt)
        return "\(day) · \(start) – \(end) \(zoneAbbreviation(tz)) · \(format.shortLabel)"
    }
}
