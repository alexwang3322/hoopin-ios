import Foundation

/// Mirrors API_CONTRACT.md's `JoinRequest`. One array of these in `RunStore` drives both the
/// host-side "Requests to play" panel (filter by `runId`) and the viewer-side "My Runs" list
/// (filter by `requesterId == currentUserId`) — same two lists the web prototype hardcodes
/// separately in markup.
///
/// At most one of these ever exists per (runId, requesterId) pair — a viewer's relationship to
/// a run is a single mutable record, not an append-only log. `RunStore.requestToJoin` resets an
/// existing withdrawn/declined row in place (same `id`) rather than appending a new one, so `id`
/// is a stable identifier for "this requester's relationship to this run," not a per-attempt id.
struct JoinRequest: Identifiable, Hashable {
    let id: String
    var runId: String
    var requesterId: String
    var message: String?
    var status: JoinRequestStatus
    var createdAt: Date
    var decidedAt: Date?
    var declineReason: String?
}

/// Mirrors API_CONTRACT.md's `HeaderCounts` — nav badge counts.
struct HeaderCounts {
    var myPendingRequests: Int
    var hostingPendingRequests: Int
}
