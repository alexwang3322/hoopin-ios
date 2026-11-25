import SwiftUI

/// Event Detail. The web's two-column layout (main content + 320px sidebar) is reflowed into one
/// scrolling column of stacked sections — the natural iOS equivalent once there's no room for
/// side-by-side columns.
struct EventDetailView: View {
    let runId: String

    @Environment(RunStore.self) private var store
    @Environment(ToastCenter.self) private var toast
    @Environment(\.navigate) private var navigate
    @State private var requestMessage: String = ""
    @State private var confirmingCancel = false

    private var run: Run? { store.run(runId) }

    var body: some View {
        if let run {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero(for: run)
                    if run.isCancelled {
                        cancelledBanner
                    } else if run.isFinished {
                        finishedBanner
                    }
                    titleBlock(for: run)
                    if let host = store.profile(run.hostId) {
                        PersonLinkView(user: host, subtitle: host.bio, avatarSize: 40)
                    }
                    Text(run.description)
                        .font(.body)
                        .foregroundStyle(Theme.textSecondary)

                    if store.viewerAction(for: run) == .host && !run.isCancelled && !run.isFinished {
                        requestsSection(for: run)
                    }

                    capacityPanel(for: run)
                    courtPanel(for: run)
                    if !store.attendees(for: run).isEmpty {
                        rosterPanel(for: run)
                    }
                    if store.viewerAction(for: run) == .host && !run.isCancelled && !run.isFinished {
                        cancelButton(for: run)
                    }
                    actionPanel(for: run)

                    Text("Approve or decline above to see the roster update.")
                        .font(.caption)
                        .foregroundStyle(Theme.textTertiary)
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle(run.title)
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Cancel this run?",
                isPresented: $confirmingCancel,
                titleVisibility: .visible
            ) {
                Button("Cancel run", role: .destructive) {
                    if store.cancel(runId: run.id) {
                        toast.show("\(run.title) has been cancelled.")
                    }
                }
                Button("Never mind", role: .cancel) {}
            } message: {
                Text("Players who requested or were approved will still see this run marked cancelled.")
            }
        } else {
            ContentUnavailableView("Run not found", systemImage: "questionmark.circle")
        }
    }

    // MARK: Sections

    private var cancelledBanner: some View {
        Text("This run has been cancelled.")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.Status.declinedFg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Theme.Status.declinedBg)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var finishedBanner: some View {
        Text("This run has finished.")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Theme.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func cancelButton(for run: Run) -> some View {
        Button("Cancel game", role: .destructive) {
            confirmingCancel = true
        }
        .buttonStyle(.bordered)
        .tint(Theme.Status.declinedFg)
    }

    private func hero(for run: Run) -> some View {
        LinearGradient(colors: [Color(hex: run.gradientStartHex), Color(hex: run.gradientEndHex)],
                        startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func titleBlock(for run: Run) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(run.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.ink)
            Text(RunFormatting.detailWhen(run))
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private func requestsSection(for run: Run) -> some View {
        let pending = store.pendingRequests(for: run.id)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Requests to play")
                    .font(.headline)
                if !pending.isEmpty {
                    StatusBadgeView(text: "\(pending.count) pending", foreground: Theme.background,
                                     background: Theme.ink, ring: Theme.ink)
                }
            }

            if pending.isEmpty {
                Text("No pending requests.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textTertiary)
            } else {
                ForEach(pending) { request in
                    if let requester = store.profile(request.requesterId) {
                        RequestCardView(
                            request: request,
                            requester: requester,
                            onApprove: {
                                if store.approve(requestId: request.id) {
                                    toast.show("\(requester.name) approved to play")
                                } else {
                                    toast.show("This run is full.")
                                }
                            },
                            onDecline: {
                                store.decline(requestId: request.id, reason: nil)
                                toast.show("\(requester.name)'s request declined")
                            }
                        )
                    }
                }
            }
        }
    }

    private func capacityPanel(for run: Run) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let capacity = run.capacity {
                    Text("\(run.goingCount) going of \(capacity)")
                        .font(.subheadline.weight(.medium))
                } else {
                    Text("\(run.goingCount) going")
                        .font(.subheadline.weight(.medium))
                }
                Spacer()
                if run.isCancelled {
                    StatusBadgeView(text: "Cancelled", foreground: Theme.Status.declinedFg,
                                     background: Theme.Status.declinedBg, ring: Theme.Status.declinedRing)
                } else if run.isFinished {
                    StatusBadgeView(text: "Finished", foreground: Theme.textTertiary,
                                     background: Theme.surfaceSecondary, ring: Theme.borderSecondary)
                } else if let badge = StatusBadgeView(viewerAction: store.viewerAction(for: run)) {
                    badge
                }
            }
            if run.capacity != nil {
                ProgressView(value: run.capacityFraction)
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
    
    private func courtPanel(for run: Run) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Court").font(.headline)
            Text(run.venueName).font(.subheadline).foregroundStyle(Theme.ink)
            if store.addressUnlocked(for: run) {
                Text(run.exactAddress).font(.subheadline).foregroundStyle(Theme.textTertiary)
            } else {
                HStack(spacing: 8) {
                    Text("🔒")
                    Text("The exact address is shared once the host approves you.")
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
        .onTapGesture {
            openInMaps(address: run.exactAddress)
        }
    }

    private func rosterPanel(for run: Run) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Who's playing").font(.headline)
            ForEach(store.attendees(for: run)) { attendee in
                PersonLinkView(user: attendee, subtitle: attendee.bio)
            }
        }
        .padding(16)
        .panelStyle()
    }

    @ViewBuilder
    private func actionPanel(for run: Run) -> some View {
        if run.isCancelled {
            Text("This run has been cancelled — no further requests can be made.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .padding(16).panelStyle()
        } else if run.isFinished {
            Text("This run has finished — no further requests can be made.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .padding(16).panelStyle()
        } else {
        switch store.viewerAction(for: run) {
        case .canRequest:
            VStack(alignment: .leading, spacing: 10) {
                Text("Tell the host a bit about your game (optional)")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textTertiary)
                TextField("Say hello…", text: $requestMessage, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Button("Request to play") {
                    store.requestToJoin(runId: run.id, message: requestMessage)
                    toast.show(store.viewerAction(for: run) == .approved
                               ? "You're in — request auto-approved."
                               : "Request sent.")
                    requestMessage = ""
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
            }
            .padding(16).panelStyle()

        case .host:
            Text("This is your run. You can't request to join your own game.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .padding(16).panelStyle()

        case .approved:
            VStack(alignment: .leading, spacing: 10) {
                Text("You're in 🎉")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.Status.playingFg)
                Button("Can't make it") {
                    if let req = store.myJoinRequest(for: run.id) {
                        store.withdraw(requestId: req.id)
                        toast.show("You've backed out of \(run.title).")
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(16).panelStyle()

        case .pending:
            VStack(alignment: .leading, spacing: 10) {
                Text("Your request is waiting on the host.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                Button("Withdraw request") {
                    if let req = store.myJoinRequest(for: run.id) {
                        store.withdraw(requestId: req.id)
                        toast.show("Request withdrawn.")
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(16).panelStyle()

        case .declined:
            VStack(alignment: .leading, spacing: 8) {
                Text("The host declined this request.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                if let reason = store.myJoinRequest(for: run.id)?.declineReason {
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
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .padding(16).panelStyle()
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
