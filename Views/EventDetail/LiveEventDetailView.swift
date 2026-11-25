import SwiftUI
import ClerkKit

/// Read-only detail for a backend-sourced run — a separate view from `EventDetailView` (mock),
/// which is tightly coupled to `RunStore`'s mock-specific lookups (`viewerAction(for:)`,
/// `profile(_:)`, etc. all assume the "Jamie Tran" mock world). This renders the server-computed
/// fields directly off the fetched object, no store needed at all — matching frontend's
/// contract-driven design. Host cancellation is wired to the backend; request/approve/decline
/// remain informational for now.
struct LiveEventDetailView: View {
    let runId: String

    @Environment(Clerk.self) private var clerk
    @Environment(AppRouter.self) private var router
    @Environment(ToastCenter.self) private var toast
    @State private var detail: LiveRunDetail?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var loadedViewerKey: String?
    @State private var showingCancelConfirmation = false
    @State private var isCancelling = false
    @State private var cancelError = ""
    @State private var showingCancelError = false

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
        .alert("Cancel this run?", isPresented: $showingCancelConfirmation) {
            Button("Cancel run", role: .destructive) { Task { await cancelRun() } }
            Button("Never mind", role: .cancel) {}
        } message: {
            Text("Players who requested or were approved will still see the run marked cancelled.")
        }
        .alert("Couldn't cancel run", isPresented: $showingCancelError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(cancelError)
        }
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

    @MainActor
    private func cancelRun() async {
        guard !isCancelling,
              let userId = clerk.user?.id,
              let current = detail,
              current.id == runId,
              current.host.id == userId,
              current.viewerAction == .host,
              !current.isCancelled,
              !current.isFinished else { return }

        isCancelling = true
        defer { isCancelling = false }
        do {
            let updated = try await LiveApiClient.cancelRun(id: runId, userId: userId)
            guard clerk.user?.id == userId, updated.id == runId else { return }
            detail = LiveMappers.toLiveRunDetail(updated)
            router.runsRevision += 1
            toast.show("Run cancelled.")
        } catch {
            guard clerk.user?.id == userId else { return }
            if case let LiveApiClient.ApiError.server(_, _, message) = error {
                cancelError = message
            } else {
                cancelError = "Couldn't cancel this run. Please try again."
            }
            showingCancelError = true
        }
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
    
    func openInMaps(address : String) {
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let appleMapsURL = URL(string: "maps://?q=\(encodedAddress)")!
        let googleMapsURL = URL(string: "comgooglemaps://?q=\(encodedAddress)")!
        
        // Check if Google Maps is installed, otherwise fallback to Apple Maps
        if UIApplication.shared.canOpenURL(googleMapsURL) {
            UIApplication.shared.open(googleMapsURL)
        } else {
            UIApplication.shared.open(appleMapsURL)
        }
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
        .onTapGesture {
            if let address = run.exactAddress {
                openInMaps(address: address)
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

    /// The host can cancel an active run. Other actions are still informational.
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
                Button(role: .destructive) {
                    showingCancelConfirmation = true
                } label: {
                    Text(isCancelling ? "Cancelling…" : "Cancel game")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(.red, lineWidth: 1)
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isCancelling)
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
