import Foundation

/// Date/time copy ported from the web prototype's fixture strings (e.g. "Sun, Sep 6 · 8:00–10:00
/// AM · 5v5 full court"), generated instead of hardcoded so it stays correct for any run.
enum RunFormatting {
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

    /// "Sun, Sep 6 · 8:00–10:00 AM · 5v5 full court" — Discover card / list-row style.
    static func cardWhen(_ run: Run) -> String {
        let tz = TimeZone(identifier: run.timezoneID) ?? .current
        let day = dayFormatter(timeZone: tz).string(from: run.startsAt)
        let start = timeFormatter(timeZone: tz).string(from: run.startsAt)
        let end = timeFormatter(timeZone: tz).string(from: run.endsAt)
        return "\(day) · \(start)–\(end) · \(run.format.shortLabel)"
    }

    /// "Sun, Sep 6 · 8:00–10:00 PM" — no format suffix, used on My Runs rows.
    static func shortWhen(_ run: Run) -> String {
        let tz = TimeZone(identifier: run.timezoneID) ?? .current
        let day = dayFormatter(timeZone: tz).string(from: run.startsAt)
        let start = timeFormatter(timeZone: tz).string(from: run.startsAt)
        let end = timeFormatter(timeZone: tz).string(from: run.endsAt)
        return "\(day) · \(start)–\(end)"
    }

    /// "Wed, Sep 9 · 12:00 PM – 1:00 PM PDT · 5v5 full court" — Event Detail heading style.
    static func detailWhen(_ run: Run) -> String {
        let tz = TimeZone(identifier: run.timezoneID) ?? .current
        let day = dayFormatter(timeZone: tz).string(from: run.startsAt)
        let start = timeFormatter(timeZone: tz).string(from: run.startsAt)
        let end = timeFormatter(timeZone: tz).string(from: run.endsAt)
        return "\(day) · \(start) – \(end) \(zoneAbbreviation(tz)) · \(run.format.shortLabel)"
    }

    static func monthAbbreviation(_ run: Run) -> String {
        let tz = TimeZone(identifier: run.timezoneID) ?? .current
        let f = DateFormatter()
        f.dateFormat = "MMM"
        f.timeZone = tz
        return f.string(from: run.startsAt).uppercased()
    }

    static func dayNumber(_ run: Run) -> String {
        let tz = TimeZone(identifier: run.timezoneID) ?? .current
        let f = DateFormatter()
        f.dateFormat = "d"
        f.timeZone = tz
        return f.string(from: run.startsAt)
    }

    static func spotsText(_ run: Run) -> String {
        guard let capacity = run.capacity else { return "\(run.goingCount) going" }
        if run.isFull { return "Full" }
        let open = capacity - run.goingCount
        return "\(run.goingCount)/\(capacity) · \(open) open"
    }
}

enum RelativeTime {
    /// "4h ago" / "1d ago" / "2d ago" — matches the web's fixture-style relative stamps.
    static func ago(from date: Date, to now: Date = Date()) -> String {
        let seconds = max(now.timeIntervalSince(date), 0)
        let hours = Int(seconds / 3600)
        if hours < 1 { return "just now" }
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        return "\(days)d ago"
    }
}
