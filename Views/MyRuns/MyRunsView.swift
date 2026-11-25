import SwiftUI
import ClerkKit
import ClerkKitUI

struct MyRunsView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(\.navigate) private var navigate
    @State private var requests: [WireJoinRequestWithRun] = []
    @State private var loadedUserId: String?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSignIn = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if clerk.user == nil {
                    ContentUnavailableView {
                        Label("Sign in to see your runs", systemImage: "person.crop.circle")
                    } description: {
                        Text("Your requests and games appear here after you sign in.")
                    } actions: {
                        Button("Sign in") { showingSignIn = true }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.accent)
                    }
                    .padding(.top, 40)
                } else if isLoading || loadedUserId != clerk.user?.id {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let errorMessage {
                    ContentUnavailableView(errorMessage, systemImage: "wifi.slash")
                        .padding(.top, 40)
                } else if requests.filter({ $0.status != "withdrawn" }).isEmpty {
                    ContentUnavailableView("There are no events now.", systemImage: "list.bullet")
                        .padding(.top, 40)
                } else {
                    ForEach(requests.filter { $0.status != "withdrawn" }, id: \.id) { request in
                        Button {
                            navigate(.liveRunDetail(request.run.id))
                        } label: {
                            LiveMyRunRowView(request: request)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("My Runs")
        .sheet(isPresented: $showingSignIn) { AuthView() }
        .task(id: clerk.user?.id) { await loadRequests() }
        .refreshable {
            if clerk.user != nil { await loadRequests() }
        }
    }

    private func loadRequests() async {
        guard let userId = clerk.user?.id else {
            requests = []
            loadedUserId = nil
            errorMessage = nil
            isLoading = false
            return
        }
        isLoading = true
        loadedUserId = nil
        errorMessage = nil
        do {
            let fetched = try await LiveApiClient.getMyRequests()
            guard !Task.isCancelled, clerk.user?.id == userId else { return }
            requests = fetched
            loadedUserId = userId
        } catch {
            guard !Task.isCancelled, clerk.user?.id == userId else { return }
            requests = []
            loadedUserId = userId
            errorMessage = "Couldn't load your runs. Pull to refresh to try again."
        }
        isLoading = false
    }
}

private struct LiveMyRunRowView: View {
    let request: WireJoinRequestWithRun

    private var run: LiveRun { LiveMappers.toLiveRun(request.run) }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: run.gradientStartHex), Color(hex: run.gradientEndHex)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(run.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(LiveRunFormatting.shortWhen(startsAt: run.startsAt, endsAt: run.endsAt,
                                                 timezoneID: run.timezoneID))
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
                if let createdAt = ISO8601DateFormatter().date(from: request.createdAt) {
                    Text("Requested \(RelativeTime.ago(from: createdAt))")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textTertiary)
                }
                if request.status == "declined", let reason = request.declineReason {
                    Text("Host said: \(reason)")
                        .font(.system(size: 13.5))
                        .foregroundStyle(Theme.Status.declinedFg)
                        .padding(10)
                        .background(Theme.Status.declinedBg)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 4)
                }
            }

            Spacer(minLength: 8)
            if let status = JoinRequestStatus(rawValue: request.status) {
                StatusBadgeView(requestStatus: status)
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Theme.border, lineWidth: 1))
    }
}
