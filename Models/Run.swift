import Foundation

/// A run/event. Merges API_CONTRACT.md's `RunSummary`/`RunDetail` split into one on-device model —
/// there is no network boundary in this mock app for `exact_address` to hide behind, so the gating
/// the contract does server-side is instead enforced by the view layer via `RunStore.viewerAction(for:)`.
struct Run: Identifiable, Hashable {
    let id: String
    var title: String
    var description: String
    var startsAt: Date
    var endsAt: Date
    var timezoneID: String
    var format: RunFormat
    var venueName: String
    var exactAddress: String
    var city: City
    var hostId: String
    var capacity: Int?
    var goingCount: Int
    var isDraft: Bool
    /// Soft-cancelled by the host — distinct from deletion, the run stays around
    /// (mirrors API_CONTRACT.md §3.1's cancel-vs-delete note / `is_cancelled`).
    var isCancelled: Bool = false
    var cancelledAt: Date? = nil
    var visibility: RunVisibility
    var autoApprove: Bool
    /// Approved roster excluding the host ("Who's playing"). Only populated where the source
    /// prototype actually demonstrates a live roster (Kezar) — every other run's `goingCount`
    /// still reflects who is going, it just isn't broken out into named rows.
    var attendeeIds: [String]
    /// Implied by the web's distance filter but not part of API_CONTRACT.md — needed for that
    /// filter to function, so it's added as an app-local field.
    var distanceMiles: Double
    var gradientStartHex: String
    var gradientEndHex: String
    var createdAt: Date

    var isFull: Bool {
        guard let capacity else { return false }
        return goingCount >= capacity
    }

    var capacityFraction: Double {
        guard let capacity, capacity > 0 else { return 0 }
        return min(Double(goingCount) / Double(capacity), 1)
    }

    var openSpots: Int? {
        guard let capacity else { return nil }
        return max(capacity - goingCount, 0)
    }
}
