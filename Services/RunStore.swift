import Foundation
import Observation

/// Single in-memory source of truth — mirrors the web prototype's global JS state
/// (`going`/`capacity`/`pending`, `PROFILES`, `RUN_DETAIL`) that many screens read and write.
/// Per-screen view models hold only transient UI state (form fields, filters) and delegate every
/// mutation here.
@Observable
final class RunStore {
    private(set) var runs: [Run]
    private(set) var profiles: [String: UserSummary]
    private(set) var joinRequests: [JoinRequest]
    private(set) var account: AccountProfile

    let currentUserId = MockData.currentUserId

    init() {
        runs = MockData.runs
        profiles = Dictionary(uniqueKeysWithValues: MockData.profiles.map { ($0.id, $0) })
        joinRequests = MockData.joinRequests
        account = MockData.currentAccount
    }

    // MARK: Lookups

    var currentUser: UserSummary { profiles[currentUserId] ?? account.user }

    func profile(_ id: String) -> UserSummary? { profiles[id] }

    func run(_ id: String) -> Run? { runs.first { $0.id == id } }

    /// Runs visible on Discover — published (non-draft) runs, sorted by start time ascending,
    /// matching the web's fixed sort order.
    var discoverRuns: [Run] {
        runs.filter { !$0.isDraft }.sorted { $0.startsAt < $1.startsAt }
    }

    /// Runs the viewer hosts, including drafts — "Hosting" screen.
    var hostingRuns: [Run] {
        runs.filter { $0.hostId == currentUserId }.sorted { $0.startsAt < $1.startsAt }
    }

    /// The viewer's own outgoing join requests, joined with their run — "My Runs" screen.
    /// Withdrawn requests are excluded: once withdrawn there is no relationship left to show.
    var myJoinRequests: [JoinRequest] {
        joinRequests
            .filter { $0.requesterId == currentUserId && $0.status != .withdrawn }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func myJoinRequest(for runId: String) -> JoinRequest? {
        joinRequests.first {
            $0.runId == runId && $0.requesterId == currentUserId && $0.status != .withdrawn
        }
    }

    /// Pending requests a host needs to review, for any run they host — generic per-run rather
    /// than hardcoded to one fixture run id.
    func pendingRequests(for runId: String) -> [JoinRequest] {
        joinRequests
            .filter { $0.runId == runId && $0.status == .pending }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func attendees(for run: Run) -> [UserSummary] {
        run.attendeeIds.compactMap { profiles[$0] }
    }

    var headerCounts: HeaderCounts {
        let mine = joinRequests.filter { $0.requesterId == currentUserId && $0.status == .pending }.count
        let hosting = runs
            .filter { $0.hostId == currentUserId }
            .reduce(0) { $0 + pendingRequests(for: $1.id).count }
        return HeaderCounts(myPendingRequests: mine, hostingPendingRequests: hosting)
    }

    // MARK: Viewer action (7-branch state machine, API_CONTRACT.md `ViewerAction`)

    func viewerAction(for run: Run) -> ViewerAction {
        if run.hostId == currentUserId { return .host }
        if let req = myJoinRequest(for: run.id) {
            switch req.status {
            case .pending: return .pending
            case .approved: return .approved
            case .declined: return .declined
            case .withdrawn: break
            }
        }
        return run.isFull ? .full : .canRequest
    }

    /// Whether the exact address is visible to the viewer for this run — unlocked for the host
    /// or an approved player, matching API_CONTRACT.md's `exact_address` presence rule.
    func addressUnlocked(for run: Run) -> Bool {
        let action = viewerAction(for: run)
        return action == .host || action == .approved
    }

    // MARK: Mutations — host side

    @discardableResult
    func approve(requestId: String) -> Bool {
        guard let idx = joinRequests.firstIndex(where: { $0.id == requestId }) else { return false }
        let runId = joinRequests[idx].runId
        guard let runIdx = runs.firstIndex(where: { $0.id == runId }) else { return false }
        guard !runs[runIdx].isFull else { return false }

        joinRequests[idx].status = .approved
        joinRequests[idx].decidedAt = Date()
        runs[runIdx].goingCount += 1
        if !runs[runIdx].attendeeIds.contains(joinRequests[idx].requesterId) {
            runs[runIdx].attendeeIds.append(joinRequests[idx].requesterId)
        }
        return true
    }

    func decline(requestId: String, reason: String?) {
        guard let idx = joinRequests.firstIndex(where: { $0.id == requestId }) else { return }
        joinRequests[idx].status = .declined
        joinRequests[idx].decidedAt = Date()
        joinRequests[idx].declineReason = reason
    }

    // MARK: Mutations — requester side
    // These two actions exist as buttons in the web markup ("Request to play", "Withdraw
    // request", "Can't make it") with no click handler wired up in the original JS — dead UI.
    // They're fully implemented here.

    /// Requesting again after a withdraw/decline resets that same row in place (same `id`)
    /// instead of appending a new one — matching API_CONTRACT.md §2's JoinRequest note: at most
    /// one row ever per (run, requester), so "My Runs" is one row per game, not one per attempt.
    @discardableResult
    func requestToJoin(runId: String, message: String?) -> Bool {
        guard let runIdx = runs.firstIndex(where: { $0.id == runId }) else { return false }
        guard runs[runIdx].hostId != currentUserId else { return false }

        let autoApprove = runs[runIdx].autoApprove && !runs[runIdx].isFull
        let newStatus: JoinRequestStatus = autoApprove ? .approved : .pending
        let trimmedMessage = message?.isEmpty == false ? message : nil

        if let existingIdx = joinRequests.firstIndex(where: { $0.runId == runId && $0.requesterId == currentUserId }) {
            guard joinRequests[existingIdx].status == .withdrawn || joinRequests[existingIdx].status == .declined else {
                return false // already active — nothing to (re)request
            }
            joinRequests[existingIdx].status = newStatus
            joinRequests[existingIdx].message = trimmedMessage
            joinRequests[existingIdx].declineReason = nil
            joinRequests[existingIdx].createdAt = Date()
            joinRequests[existingIdx].decidedAt = autoApprove ? Date() : nil
        } else {
            let request = JoinRequest(
                id: "req_\(UUID().uuidString.prefix(8))",
                runId: runId,
                requesterId: currentUserId,
                message: trimmedMessage,
                status: newStatus,
                createdAt: Date(),
                decidedAt: autoApprove ? Date() : nil,
                declineReason: nil
            )
            joinRequests.append(request)
        }

        if autoApprove {
            runs[runIdx].goingCount += 1
            if !runs[runIdx].attendeeIds.contains(currentUserId) {
                runs[runIdx].attendeeIds.append(currentUserId)
            }
        }
        return true
    }

    /// Withdraws a pending request, or backs out of an approved one — one endpoint either way,
    /// matching API_CONTRACT.md's single `withdraw` action and its open-question note that both
    /// map to the same `withdrawn` status.
    func withdraw(requestId: String) {
        guard let idx = joinRequests.firstIndex(where: { $0.id == requestId }) else { return }
        let wasApproved = joinRequests[idx].status == .approved
        joinRequests[idx].status = .withdrawn
        joinRequests[idx].decidedAt = Date()

        if wasApproved, let runIdx = runs.firstIndex(where: { $0.id == joinRequests[idx].runId }) {
            runs[runIdx].goingCount = max(runs[runIdx].goingCount - 1, 0)
            runs[runIdx].attendeeIds.removeAll { $0 == joinRequests[idx].requesterId }
        }
    }

    // MARK: Mutations — cancel

    /// Cancels a run the viewer hosts — soft, not a delete: the run and its join-request
    /// history stay around, just marked. Mirrors `POST /runs/{id}/cancel` (API_CONTRACT.md §3.1).
    @discardableResult
    func cancel(runId: String) -> Bool {
        guard let idx = runs.firstIndex(where: { $0.id == runId }) else { return false }
        guard runs[idx].hostId == currentUserId else { return false }
        guard !runs[idx].isCancelled else { return false }
        runs[idx].isCancelled = true
        runs[idx].cancelledAt = Date()
        return true
    }

    // MARK: Mutations — hosting / create

    /// Publishes a new run, or — if `draftId` names an existing draft — publishes that draft in
    /// place instead of prepending a duplicate row (the original prototype always prepends a new
    /// Hosting row even when editing a draft; this fixes that).
    @discardableResult
    func publish(_ form: CreateRunFormValues, draftId: String?) -> String {
        if let draftId, let idx = runs.firstIndex(where: { $0.id == draftId }) {
            runs[idx] = form.makeRun(id: draftId, hostId: currentUserId, isDraft: false,
                                      existingAttendeeIds: runs[idx].attendeeIds,
                                      existingGoingCount: runs[idx].goingCount,
                                      gradientStart: runs[idx].gradientStartHex,
                                      gradientEnd: runs[idx].gradientEndHex)
            return draftId
        } else {
            let id = "ev_\(UUID().uuidString.prefix(8))"
            let run = form.makeRun(id: id, hostId: currentUserId, isDraft: false,
                                    existingAttendeeIds: [], existingGoingCount: 0,
                                    gradientStart: "E0954B", gradientEnd: "5C3A17")
            runs.insert(run, at: 0)
            return id
        }
    }

    func saveDraft(_ form: CreateRunFormValues, draftId: String?) {
        if let draftId, let idx = runs.firstIndex(where: { $0.id == draftId }) {
            runs[idx] = form.makeRun(id: draftId, hostId: currentUserId, isDraft: true,
                                      existingAttendeeIds: runs[idx].attendeeIds,
                                      existingGoingCount: runs[idx].goingCount,
                                      gradientStart: runs[idx].gradientStartHex,
                                      gradientEnd: runs[idx].gradientEndHex)
        } else {
            let id = "ev_\(UUID().uuidString.prefix(8))"
            let run = form.makeRun(id: id, hostId: currentUserId, isDraft: true,
                                    existingAttendeeIds: [], existingGoingCount: 0,
                                    gradientStart: "E0954B", gradientEnd: "5C3A17")
            runs.insert(run, at: 0)
        }
    }

    // MARK: Mutations — account

    func updateAccount(_ profile: AccountProfile) {
        account = profile
        profiles[profile.user.id] = profile.user
    }
}
