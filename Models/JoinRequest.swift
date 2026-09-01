import Foundation

/// Mirrors API_CONTRACT.md's `JoinRequest`. One array of these in `RunStore` drives both the
/// host-side "Requests to play" panel (filter by `runId`) and the viewer-side "My Runs" list
/// (filter by `requesterId == currentUserId`) — same two lists the web prototype hardcodes
/// separately in markup.
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
