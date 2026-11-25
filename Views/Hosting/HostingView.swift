import SwiftUI
import ClerkKit
import ClerkKitUI

struct HostingView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(\.navigate) private var navigate
    @State private var runs: [LiveRun] = []
    @State private var loadedUserId: String?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSignIn = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if clerk.user == nil {
                    ContentUnavailableView {
                        Label("Sign in to see your hosted runs", systemImage: "person.crop.circle")
                    } description: {
                        Text("Runs you host appear here after you sign in.")
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
                } else if runs.isEmpty {
                    ContentUnavailableView("There are no events now.", systemImage: "person.3")
                        .padding(.top, 40)
                } else {
                    ForEach(runs) { run in
                        Button {
                            navigate(.liveRunDetail(run.id))
                        } label: {
                            HostingRowView(run: run)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("Hosting")
        .sheet(isPresented: $showingSignIn) { AuthView() }
        .task(id: clerk.user?.id) { await loadRuns() }
        .refreshable {
            if clerk.user != nil { await loadRuns() }
        }
    }

    private func loadRuns() async {
        guard let userId = clerk.user?.id else {
            runs = []
            loadedUserId = nil
            errorMessage = nil
            isLoading = false
            return
        }
        isLoading = true
        loadedUserId = nil
        errorMessage = nil
        do {
            let fetched = try await LiveApiClient.getHosting()
            guard !Task.isCancelled, clerk.user?.id == userId else { return }
            runs = fetched.map(LiveMappers.toLiveRun)
            loadedUserId = userId
        } catch {
            guard !Task.isCancelled, clerk.user?.id == userId else { return }
            runs = []
            loadedUserId = userId
            errorMessage = "Couldn't load your hosted runs. Pull to refresh to try again."
        }
        isLoading = false
    }
}
