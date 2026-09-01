import SwiftUI

struct DiscoverView: View {
    @Environment(RunStore.self) private var store
    @State private var filters = DiscoverFilterViewModel()
    @State private var showingFilters = false
    @State private var showingCreate = false
    /// Cosmetic only, exactly like the web's SF/OAK segmented control — it never filters the feed.
    @State private var selectedCity: City = .sf

    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 20)]

    private var visibleRuns: [Run] {
        store.discoverRuns.filter { filters.matches($0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker("City", selection: $selectedCity) {
                    ForEach(City.allCases) { city in
                        Text(city.label).tag(city)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 220)
                .padding(.horizontal, 16)

                if visibleRuns.isEmpty {
                    ContentUnavailableView("There are no events now.", systemImage: "sportscourt")
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(visibleRuns) { run in
                            RunCardView(run: run)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                Text("Spots update once requests are approved.")
                    .font(.caption)
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .background(Theme.background)
        .navigationTitle("Discover")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingFilters = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCreate = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            DiscoverFilterSheet(filters: filters)
        }
        .sheet(isPresented: $showingCreate) {
            CreateRunView(viewModel: CreateRunFormViewModel())
        }
    }
}
