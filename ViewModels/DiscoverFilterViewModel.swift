import Foundation
import Observation

/// Discover's filter-bar state: from-date, format, distance. Cards themselves never leave the
/// data set — filtering only changes which ones are visible — mirroring the web's comment that
/// "sort order never changes; filtering just shows/hides."
@Observable
final class DiscoverFilterViewModel {
    var fromDate: Date
    var format: RunFormat?
    var maxDistanceMiles: Double?

    init() {
        fromDate = Calendar.current.startOfDay(for: Date())
    }

    func clear() {
        fromDate = Calendar.current.startOfDay(for: Date())
        format = nil
        maxDistanceMiles = nil
    }

    func matches(_ run: Run) -> Bool {
        let matchesDate = run.startsAt >= fromDate
        let matchesFormat = format == nil || run.format == format
        let matchesDistance = maxDistanceMiles == nil || run.distanceMiles <= maxDistanceMiles!
        return matchesDate && matchesFormat && matchesDistance
    }
}
