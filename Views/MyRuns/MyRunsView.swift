import SwiftUI

struct MyRunsView: View {
    @Environment(RunStore.self) private var store
    @Environment(\.navigate) private var navigate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if store.myJoinRequests.isEmpty {
                    ContentUnavailableView("There are no events now.", systemImage: "list.bullet")
                        .padding(.top, 40)
                } else {
                    ForEach(store.myJoinRequests) { request in
                        if let run = store.run(request.runId) {
                            Button {
                                navigate(.runDetail(run.id))
                            } label: {
                                MyRunRowView(request: request, run: run)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("My Runs")
    }
}
