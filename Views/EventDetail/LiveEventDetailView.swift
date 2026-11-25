import SwiftUI
import ClerkKit

/// Read-only detail for a backend-sourced run — a separate view from `EventDetailView` (mock),
/// which is tightly coupled to `RunStore`'s mock-specific lookups (`viewerAction(for:)`,
/// `profile(_:)`, etc. all assume the "Jamie Tran" mock world). This renders the server-computed
/// fields directly off the fetched object, no store needed at all — matching frontend's
/// contract-driven design. Request/approve/decline/cancel aren't wired yet (this pass is
/// read-only browsing only) — the action panel shows the real state informationally rather than
/// with working buttons.
struct LiveEventDetailView: View {
    let runId: String

    @Environment(Clerk.self) private var clerk
    @State private var detail: LiveRunDetail?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var loadedViewerKey: String?

    private var viewerKey: String { clerk.user?.id ?? "guest" }

    var body: some View {
        Group {
            if loadedViewerKey != viewerKey {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail {
                content(for: detail)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView(errorMessage ?? "Run not found", systemImage: "questionmark.circle")
            }
        }
        .background(Theme.background)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: viewerKey) { await load() }
    }

    private func load() async {
        let requestedViewerKey = viewerKey
        detail = nil
        loadedViewerKey = nil
        isLoading = true
        do {
            let wire = try await LiveApiClient.getRun(id: runId)
            guard !Task.isCancelled, viewerKey == requestedViewerKey else { return }
            detail = LiveMappers.toLiveRunDetail(wire)
        } catch {
            guard !Task.isCancelled, viewerKey == requestedViewerKey else { return }
            errorMessage = "Couldn't load this run."
        }
        loadedViewerKey = requestedViewerKey
        isLoading = false
    }

    @ViewBuilder
    private func content(for run: LiveRunDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero(for: run)
                if run.isCancelled {
                    banner("This run has been cancelled.", fg: Theme.Status.declinedFg, bg: Theme.Status.declinedBg)
                } else if run.isFinished {
                    banner("This run has finished.", fg: Theme.textSecondary, bg: Theme.surfaceSecondary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(run.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.ink)
                    Text(LiveRunFormatting.detailWhen(startsAt: run.startsAt, endsAt: run.endsAt,
                                                       timezoneID: run.timezoneID, format: run.format))
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                PersonLinkView(user: run.host, subtitle: run.host.bio, avatarSize: 40)
                Text(run.description)
                    .font(.body)
                    .foregroundStyle(Theme.textSecondary)

                capacityPanel(for: run)
                courtPanel(for: run)
                if !run.attendees.isEmpty {
                    rosterPanel(for: run)
                }
                actionPanel(for: run)
            }
            .padding(16)
        }
        .navigationTitle(run.title)
    }

    private func banner(_ text: String, fg: Color, bg: Color) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(fg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func hero(for run: LiveRunDetail) -> some View {
        LinearGradient(colors: [Color(hex: run.gradientStartHex), Color(hex: run.gradientEndHex)],
                        startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func capacityPanel(for run: LiveRunDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let capacity = run.capacity {
                Text("\(run.goingCount) going of \(capacity)")
                    .font(.subheadline.weight(.medium))
            } else {
                Text("\(run.goingCount) going")
                    .font(.subheadline.weight(.medium))
            }
            if let capacity = run.capacity, capacity > 0 {
                ProgressView(value: min(Double(run.goingCount) / Double(capacity), 1))
                    .tint(Theme.ink)
            }
        }
        .padding(16)
        .panelStyle()
    }

    private func courtPanel(for run: LiveRunDetail) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Court").font(.headline)
            Text(run.venueName).font(.subheadline).foregroundStyle(Theme.ink)
            if let address = run.exactAddress {
                Text(address).font(.subheadline).foregroundStyle(Theme.textTertiary)
            } else {
                HStack(spacing: 8) {
                    Text("🔒")
                    Text(run.addressLockedReason == "signed_out"
                         ? "Sign in and get approved to see the exact address."
                         : "The exact address is shared once the host approves you.")
                        .font(.system(size: 13.5))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(10)
                .background(Theme.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .panelStyle()
    }

    private func rosterPanel(for run: LiveRunDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Who's playing").font(.headline)
            ForEach(run.attendees) { attendee in
                PersonLinkView(user: attendee, subtitle: attendee.bio)
            }
        }
        .padding(16)
        .panelStyle()
    }

    /// Informational only — matches the real 7-branch state, but request/approve/decline aren't
    /// wired yet (read-only pass), so this shows what would happen rather than a working action.
    @ViewBuilder
    private func actionPanel(for run: LiveRunDetail) -> some View {
        if run.isCancelled {
            Text("This run has been cancelled — no further requests can be made.")
                .font(.subheadline).foregroundStyle(Theme.textSecondary).padding(16).panelStyle()
        } else if run.isFinished {
            Text("This run has finished — no further requests can be made.")
                .font(.subheadline).foregroundStyle(Theme.textSecondary).padding(16).panelStyle()
        } else {
            switch run.viewerAction {
            case .signedOut:
                Text("Sign in to request to play.")
                    .font(.subheadline).foregroundStyle(Theme.textSecondary).padding(16).panelStyle()
            case .canRequest:
                Text("Requesting to play isn't available in the app yet — use the web app for now.")
                    .font(.subheadline).foregroundStyle(Theme.textSecondary).padding(16).panelStyle()
            case .host:
                VStack(alignment: .leading, spacing: 10) {
                    Text("This is your run.")
                        .font(.subheadline).foregroundStyle(Theme.textSecondary)
                    if let pending = run.pendingRequests, !pending.isEmpty {
                        Text("\(run.pendingCount ?? pending.count) pending request(s) — review them on the web app for now.")
                            .font(.system(size: 13.5)).foregroundStyle(Theme.textTertiary)
                    }
                }
                .padding(16).panelStyle()
            case .approved:
                Text("You're in 🎉")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.Status.playingFg)
                    .padding(16).panelStyle()
            case .pending:
                Text("Your request is waiting on the host.")
                    .font(.subheadline).foregroundStyle(Theme.textSecondary).padding(16).panelStyle()
            case .declined:
                VStack(alignment: .leading, spacing: 8) {
                    Text("The host declined this request.")
                        .font(.subheadline).foregroundStyle(Theme.textSecondary)
                    if let reason = run.viewerRequest?.declineReason {
                        Text("Host said: \(reason)")
                            .font(.system(size: 13.5))
                            .foregroundStyle(Theme.Status.declinedFg)
                            .padding(10)
                            .background(Theme.Status.declinedBg)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(16).panelStyle()
            case .full:
                Text("This run is full.")
                    .font(.subheadline).foregroundStyle(Theme.textSecondary).padding(16).panelStyle()
            }
        }
    }
}

private extension View {
    func panelStyle() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Theme.border, lineWidth: 1)
            )
    }
}
