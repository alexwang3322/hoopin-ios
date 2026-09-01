import SwiftUI

struct HostingView: View {
    @Environment(RunStore.self) private var store
    @Environment(\.navigate) private var navigate
    @State private var showingCreate = false
    @State private var editingDraft: Run?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if store.hostingRuns.isEmpty {
                    ContentUnavailableView("There are no events now.", systemImage: "person.3")
                        .padding(.top, 40)
                } else {
                    ForEach(store.hostingRuns) { run in
                        Button {
                            if run.isDraft {
                                editingDraft = run
                            } else {
                                navigate(.runDetail(run.id))
                            }
                        } label: {
                            HostingRowView(run: run, pendingCount: store.pendingRequests(for: run.id).count)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("Hosting")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCreate = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingCreate) {
            CreateRunView(viewModel: CreateRunFormViewModel())
        }
        .sheet(item: $editingDraft) { run in
            CreateRunView(viewModel: CreateRunFormViewModel(editingDraft: run))
        }
    }
}
