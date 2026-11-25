import SwiftUI
import ClerkKit

private struct DraftEditor: Identifiable {
    let id: String
    let viewModel: CreateRunFormViewModel
}

struct HostingView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(AppRouter.self) private var router
    @Environment(ToastCenter.self) private var toast
    @Environment(\.navigate) private var navigate
    @State private var runs: [LiveRun] = []
    @State private var loadedUserId: String?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingCreate = false
    @State private var createViewModel = CreateRunFormViewModel()
    @State private var draftEditor: DraftEditor?
    @State private var loadingDraftId: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if clerk.user == nil {
                    ContentUnavailableView {
                        Label("Sign in to see your hosted runs", systemImage: "person.crop.circle")
                    } description: {
                        Text("Runs you host appear here after you sign in.")
                    } actions: {
                        Button("Sign in") { router.showingSignIn = true }
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
                            if run.isDraft {
                                Task { await openDraft(id: run.id) }
                            } else {
                                navigate(.liveRunDetail(run.id))
                            }
                        } label: {
                            HostingRowView(run: run)
                        }
                        .buttonStyle(.plain)
                        .disabled(loadingDraftId != nil)
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("Hosting")
        .toolbar {
            if clerk.user != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        createViewModel = CreateRunFormViewModel()
                        showingCreate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreate) {
            CreateRunView(viewModel: createViewModel)
        }
        .sheet(item: $draftEditor) { editor in
            CreateRunView(viewModel: editor.viewModel)
        }
        .task(id: "\(clerk.user?.id ?? "guest")-\(router.runsRevision)") { await loadRuns() }
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

    private func openDraft(id: String) async {
        guard let userId = clerk.user?.id, loadingDraftId == nil else { return }
        loadingDraftId = id
        defer { loadingDraftId = nil }
        do {
            let wire = try await LiveApiClient.getRun(id: id)
            guard !Task.isCancelled, clerk.user?.id == userId, wire.isDraft else { return }
            let detail = LiveMappers.toLiveRunDetail(wire)
            draftEditor = DraftEditor(id: id, viewModel: CreateRunFormViewModel(editingDraft: detail))
        } catch {
            guard clerk.user?.id == userId else { return }
            toast.show("Couldn't open this draft. Please try again.")
        }
    }
}
