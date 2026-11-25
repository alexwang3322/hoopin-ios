import Foundation

/// Read-only models for backend-sourced (real) runs — deliberately separate from `Run`/
/// `RunStore`'s mock world rather than bolted onto it: `Run.exactAddress`/`hostId`-based lookups
/// assume a mock store (`RunStore.viewerAction(for:)`, `RunStore.profile(_:)`) that has no
/// relationship to real data, and API_CONTRACT.md's server-computed fields (`viewer_action`,
/// `exact_address`-or-locked-reason, embedded `host`/`attendees`) need no store lookup at all —
/// they're just properties on the fetched object, mirroring frontend's contract-driven design.
/// The existing mock EventDetailView still uses RunStore fixtures.

/// Card-list shape (`viewer_status`) — distinct from `LiveViewerAction` (detail-only); the
/// contract itself keeps these as two separate enums (§2).
enum LiveViewerStatus: String {
    case host, pending, approved, declined, withdrawn
}

/// The 7-branch action-panel state (API_CONTRACT.md's `ViewerAction`), including `signedOut` —
/// unlike the mock `ViewerAction` enum, which omits it since the mock world has no signed-out
/// concept at all.
enum LiveViewerAction: String {
    case signedOut = "signed_out"
    case canRequest = "can_request"
    case host, pending, approved, declined, full
}

struct LiveRun: Identifiable {
    let id: String
    let title: String
    let startsAt: Date
    let endsAt: Date
    let timezoneID: String
    let format: RunFormat
    let venueName: String
    let city: City
    let host: UserSummary
    let capacity: Int?
    let goingCount: Int
    let isFull: Bool
    let isDraft: Bool
    let isCancelled: Bool
    let visibility: RunVisibility
    let viewerStatus: LiveViewerStatus?
    let gradientStartHex: String
    let gradientEndHex: String

    var isFinished: Bool { endsAt <= Date() }
}

struct LiveJoinRequest: Identifiable {
    let id: String
    let requester: UserSummary
    let message: String?
    let status: String
    let declineReason: String?
}

struct LiveRunDetail: Identifiable {
    let id: String
    let title: String
    let description: String
    let startsAt: Date
    let endsAt: Date
    let timezoneID: String
    let format: RunFormat
    let venueName: String
    let city: City
    let host: UserSummary
    let capacity: Int?
    let goingCount: Int
    let isFull: Bool
    let isDraft: Bool
    let isCancelled: Bool
    let visibility: RunVisibility
    let autoApprove: Bool
    let gradientStartHex: String
    let gradientEndHex: String

    /// Present only if the viewer is the host or their own request is approved — absent
    /// otherwise. `addressLockedReason` explains why when this is nil.
    let exactAddress: String?
    let addressLockedReason: String?
    let attendees: [UserSummary]
    let viewerAction: LiveViewerAction
    let viewerRequest: LiveJoinRequest?
    let pendingRequests: [LiveJoinRequest]?
    let pendingCount: Int?

    var isFinished: Bool { endsAt <= Date() }
}
