import SwiftUI

/// Wired to backend/'s live API (GET /runs) — real data, not RunStore's mock fixtures. My Runs/
/// Hosting/Create Run stay on mock data (see LiveEventDetailView's note); tapping a card here
/// goes to `.liveRunDetail`, a separate read-only detail screen, not the mock `EventDetailView`.
struct DiscoverView: View {
    @Environment(\.navigate) private var navigate
    @State private var liveVM = LiveDiscoverViewModel()
    @State private var filters = DiscoverFilterViewModel()
    @State private var showingFilters = false
    @State private var showingCreate = false
    /// Defaults to San Diego, matching the web's default.
    @State private var selectedCity: City = .sd

    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 20)]

    /// The API filters by city/format server-side; "from date" has no query param
    /// (API_CONTRACT.md §6 only lists city/format), so it's applied client-side here, same as
    /// the mock filter's own logic.
    private var visibleRuns: [LiveRun] {
        liveVM.runs.filter { $0.startsAt >= filters.fromDate }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    Picker("City", selection: $selectedCity) {
                        ForEach(City.allCases) { city in
                            Text(city.label).tag(city)
                        }
                    }
                    .pickerStyle(.menu)

                    // Visible inline, matching the web's always-shown "From date" field —
                    // Game type stays in the filter sheet (⋯ toolbar icon) alongside it.
                    HStack(spacing: 6) {
                        Text("From")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                        DatePicker("From date", selection: $filters.fromDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
                .padding(.horizontal, 16)

                if liveVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let errorMessage = liveVM.errorMessage {
                    ContentUnavailableView(errorMessage, systemImage: "wifi.slash")
                        .padding(.top, 40)
                } else if visibleRuns.isEmpty {
                    ContentUnavailableView("There are no events now.", systemImage: "sportscourt")
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(visibleRuns) { run in
                            LiveRunCardView(run: run) {
                                navigate(.liveRunDetail(run.id))
                            }
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
        .task(id: "\(selectedCity.rawValue)-\(filters.format?.rawValue ?? "")") {
            await liveVM.load(city: selectedCity, format: filters.format)
        }
        .refreshable {
            await liveVM.load(city: selectedCity, format: filters.format)
        }
    }
}
