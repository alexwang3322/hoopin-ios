import SwiftUI

/// Discover's filter bar (from-date, format, distance) reinterpreted as a sheeted Form —
/// the web's inline filter row doesn't fit iOS's narrower nav-bar-first layout.
struct DiscoverFilterSheet: View {
    @Bindable var filters: DiscoverFilterViewModel
    @Environment(\.dismiss) private var dismiss

    private let distanceOptions: [Double?] = [nil, 2, 5, 10]

    var body: some View {
        NavigationStack {
            Form {
                Section("From date") {
                    DatePicker("From date", selection: $filters.fromDate, displayedComponents: .date)
                        .labelsHidden()
                }

                Section("Game type") {
                    Picker("Game type", selection: $filters.format) {
                        Text("Any format").tag(RunFormat?.none)
                        ForEach(RunFormat.allCases) { format in
                            Text(format.displayName).tag(RunFormat?.some(format))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Distance") {
                    Picker("Distance", selection: $filters.maxDistanceMiles) {
                        Text("Any distance").tag(Double?.none)
                        ForEach(distanceOptions.dropFirst().compactMap { $0 }, id: \.self) { distance in
                            Text("Within \(Int(distance)) mi").tag(Double?.some(distance))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Filter runs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") { filters.clear() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
