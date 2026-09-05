import Foundation

/// Wire (snake_case, from LiveApiClient) -> the read-only Live* models above.
enum LiveMappers {
    private static let isoFormatter = ISO8601DateFormatter()

    private static func parseDate(_ string: String) -> Date {
        isoFormatter.date(from: string) ?? Date()
    }

    static func toUserSummary(_ w: WireUserSummary) -> UserSummary {
        UserSummary(id: w.id, name: w.name, initials: w.initials, bio: w.bio,
                    avatarColorHex: ColorHash.avatarColorHex(for: w.id))
    }

    private static func toCity(_ raw: String) -> City {
        City(rawValue: raw) ?? .sf
    }

    private static func toFormat(_ raw: String) -> RunFormat {
        RunFormat(rawValue: raw) ?? .fiveVFiveFullCourt
    }

    private static func toVisibility(_ raw: String) -> RunVisibility {
        RunVisibility(rawValue: raw) ?? .publicVisibility
    }

    static func toLiveRun(_ w: WireRunSummary) -> LiveRun {
        let gradient = ColorHash.coverGradient(for: w.coverSeed)
        return LiveRun(
            id: w.id, title: w.title,
            startsAt: parseDate(w.startsAt), endsAt: parseDate(w.endsAt), timezoneID: w.timezone,
            format: toFormat(w.format), venueName: w.venueName, city: toCity(w.city),
            host: toUserSummary(w.host), capacity: w.capacity, goingCount: w.goingCount,
            isFull: w.isFull, isDraft: w.isDraft, isCancelled: w.isCancelled,
            visibility: toVisibility(w.visibility),
            viewerStatus: w.viewerStatus.flatMap(LiveViewerStatus.init(rawValue:)),
            gradientStartHex: gradient.start, gradientEndHex: gradient.end
        )
    }

    private static func toJoinRequest(_ w: WireJoinRequest) -> LiveJoinRequest {
        LiveJoinRequest(id: w.id, requester: toUserSummary(w.requester), message: w.message,
                         status: w.status, declineReason: w.declineReason)
    }

    static func toLiveRunDetail(_ w: WireRunDetail) -> LiveRunDetail {
        let gradient = ColorHash.coverGradient(for: w.coverSeed)
        return LiveRunDetail(
            id: w.id, title: w.title, description: w.description,
            startsAt: parseDate(w.startsAt), endsAt: parseDate(w.endsAt), timezoneID: w.timezone,
            format: toFormat(w.format), venueName: w.venueName, city: toCity(w.city),
            host: toUserSummary(w.host), capacity: w.capacity, goingCount: w.goingCount,
            isFull: w.isFull, isDraft: w.isDraft, isCancelled: w.isCancelled,
            visibility: toVisibility(w.visibility), autoApprove: w.autoApprove,
            gradientStartHex: gradient.start, gradientEndHex: gradient.end,
            exactAddress: w.exactAddress, addressLockedReason: w.addressLockedReason,
            attendees: w.attendees.map(toUserSummary),
            viewerAction: LiveViewerAction(rawValue: w.viewerAction) ?? .signedOut,
            viewerRequest: w.viewerRequest.map(toJoinRequest),
            pendingRequests: w.pendingRequests?.items.map(toJoinRequest),
            pendingCount: w.pendingRequests?.pendingCount
        )
    }
}
