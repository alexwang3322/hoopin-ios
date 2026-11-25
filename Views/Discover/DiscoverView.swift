import SwiftUI
import ClerkKit

/// Wired to backend/'s live API (GET /runs) — real data, not RunStore's mock fixtures.
/// Tapping a card goes to `.liveRunDetail`, a separate read-only detail screen.
struct DiscoverView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(AppRouter.self) private var router
    @Environment(\.navigate) private var navigate
    @State private var liveVM = LiveDiscoverViewModel()
    @State private var filters = DiscoverFilterViewModel()
    @State private var showingFilters = false
    @State private var showingCreate = false
    @State private var createViewModel = CreateRunFormViewModel()
    @State private var loadedViewerKey: String?
    /// Defaults to San Diego, matching the web's default.
    @State private var selectedCity: City = .sd
    @State private var showingDatePicker = false

    private let columns = [GridItem(.adaptive(minimum: 300), spacing: 20)]

    private var viewerKey: String { clerk.user?.id ?? "guest" }

    private var fromDateLabel: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: filters.fromDate)
    }

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
                    // Game type stays in the filter sheet (⋯ toolbar icon) alongside it. A plain
                    // Button (rather than DatePicker's own .compact style, which always draws its
                    // own gray pill background) so this reads as plain accent-colored text, same
                    // as the City picker above.
                    Button {
                        showingDatePicker = true
                    } label: {
                        Text(fromDateLabel)
                    }
                    .popover(isPresented: $showingDatePicker) {
                        // .graphical has no intrinsic width of its own — left unconstrained in a
                        // popover it collapses to a single narrow column of day numbers instead of
                        // the full calendar grid, so it needs an explicit width here.
                        DatePicker("From date", selection: $filters.fromDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .frame(width: 320)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                    }
                }
                .padding(.horizontal, 16)

                if liveVM.isLoading || loadedViewerKey != viewerKey {
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
                    if clerk.user == nil {
                        router.showingSignIn = true
                    } else {
                        createViewModel = CreateRunFormViewModel()
                        showingCreate = true
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            DiscoverFilterSheet(filters: filters)
        }
        .sheet(isPresented: $showingCreate) {
            CreateRunView(viewModel: createViewModel)
        }
        .task(id: "\(viewerKey)-\(selectedCity.rawValue)-\(filters.format?.rawValue ?? "")-\(router.runsRevision)") {
            let requestedViewerKey = viewerKey
            loadedViewerKey = nil
            await liveVM.load(city: selectedCity, format: filters.format)
            if !Task.isCancelled, viewerKey == requestedViewerKey {
                loadedViewerKey = requestedViewerKey
            }
        }
        .refreshable {
            await liveVM.load(city: selectedCity, format: filters.format)
        }
    }
}
