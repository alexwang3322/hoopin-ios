import Foundation

/// Snake_case wire shapes exactly as API_CONTRACT.md §2 defines them — mirrors
/// frontend/src/services/wireTypes.ts. Only the fields used by the read-only screens are
/// modeled here.

struct WireUserSummary: Codable {
    let id: String
    let name: String
    let initials: String
    let bio: String?
}

struct WireJoinRequest: Codable {
    let id: String
    let runId: String
    let requester: WireUserSummary
    let message: String?
    let status: String
    let createdAt: String
    let decidedAt: String?
    let declineReason: String?

    enum CodingKeys: String, CodingKey {
        case id
        case runId = "run_id"
        case requester, message, status
        case createdAt = "created_at"
        case decidedAt = "decided_at"
        case declineReason = "decline_reason"
    }
}

/// GET /me/requests embeds the run alongside each of the viewer's requests.
struct WireJoinRequestWithRun: Codable {
    let id: String
    let status: String
    let createdAt: String
    let declineReason: String?
    let run: WireRunSummary

    enum CodingKeys: String, CodingKey {
        case id, status, run
        case createdAt = "created_at"
        case declineReason = "decline_reason"
    }
}

struct WirePendingRequests: Codable {
    let items: [WireJoinRequest]
    let pendingCount: Int

    enum CodingKeys: String, CodingKey {
        case items
        case pendingCount = "pending_count"
    }
}

/// GET /runs row shape. `RunDetail` (below) extends this with the same keys plus its own, so both
/// decode through this same set of `CodingKeys.summary` fields.
struct WireRunSummary: Codable {
    let id: String
    let title: String
    let startsAt: String
    let endsAt: String
    let timezone: String
    let format: String
    let venueName: String
    let city: String
    let host: WireUserSummary
    let capacity: Int?
    let goingCount: Int
    let isFull: Bool
    let isDraft: Bool
    let isCancelled: Bool
    let cancelledAt: String?
    let visibility: String
    let viewerStatus: String?
    let coverSeed: String

    enum CodingKeys: String, CodingKey {
        case id, title
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case timezone, format
        case venueName = "venue_name"
        case city, host, capacity
        case goingCount = "going_count"
        case isFull = "is_full"
        case isDraft = "is_draft"
        case isCancelled = "is_cancelled"
        case cancelledAt = "cancelled_at"
        case visibility
        case viewerStatus = "viewer_status"
        case coverSeed = "cover_seed"
    }
}

/// GET /runs/{id} shape. Decoded as its own type (not `WireRunSummary` + extra fields) since
/// Swift's Codable doesn't compose via inheritance the way the contract's TS `extends` does —
/// duplicates the summary fields plus the detail-only ones.
struct WireRunDetail: Codable {
    let id: String
    let title: String
    let startsAt: String
    let endsAt: String
    let timezone: String
    let format: String
    let venueName: String
    let city: String
    let host: WireUserSummary
    let capacity: Int?
    let goingCount: Int
    let isFull: Bool
    let isDraft: Bool
    let isCancelled: Bool
    let cancelledAt: String?
    let visibility: String
    let viewerStatus: String?
    let coverSeed: String

    let description: String
    let autoApprove: Bool
    let createdAt: String
    let exactAddress: String?
    let addressLockedReason: String?
    let attendees: [WireUserSummary]
    let viewerAction: String
    let viewerRequest: WireJoinRequest?
    let pendingRequests: WirePendingRequests?

    enum CodingKeys: String, CodingKey {
        case id, title
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case timezone, format
        case venueName = "venue_name"
        case city, host, capacity
        case goingCount = "going_count"
        case isFull = "is_full"
        case isDraft = "is_draft"
        case isCancelled = "is_cancelled"
        case cancelledAt = "cancelled_at"
        case visibility
        case viewerStatus = "viewer_status"
        case coverSeed = "cover_seed"
        case description
        case autoApprove = "auto_approve"
        case createdAt = "created_at"
        case exactAddress = "exact_address"
        case addressLockedReason = "address_locked_reason"
        case attendees
        case viewerAction = "viewer_action"
        case viewerRequest = "viewer_request"
        case pendingRequests = "pending_requests"
    }
}

struct WireCursorPage<T: Codable>: Codable {
    let items: [T]
    let nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case items
        case nextCursor = "next_cursor"
    }
}

struct WireApiError: Codable {
    struct Body: Codable {
        let code: String
        let message: String
        let field: String?
    }
    let error: Body
}
