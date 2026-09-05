import SwiftUI

/// The "Host a run" form, reinterpreted as a sectioned native `Form` inside a sheet rather than
/// the web's single scrolling column. Section grouping mirrors the web's field order: Basics,
/// Date & Time, Format, Location, Capacity & Visibility, auto-approve.
struct CreateRunView: View {
    @Bindable var viewModel: CreateRunFormViewModel

    @Environment(RunStore.self) private var store
    @Environment(ToastCenter.self) private var toast
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $viewModel.values.title)
                    TextField("Description", text: $viewModel.values.description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Basics")
                } footer: {
                    Text(viewModel.subtitle)
                }

                Section {
                    DatePicker("Date", selection: $viewModel.values.date, displayedComponents: .date)
                    DatePicker("Start", selection: $viewModel.values.startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $viewModel.values.endTime, displayedComponents: .hourAndMinute)
                    TextField("Timezone", text: $viewModel.values.timezoneID)
                } header: {
                    Text("Date & time")
                } footer: {
                    Text("Times always display in the run's zone.")
                }

                Section("Format") {
                    Picker("Format", selection: $viewModel.values.format) {
                        ForEach(RunFormat.allCases) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section {
                    TextField("Court name", text: $viewModel.values.venueName)
                    TextField("Exact address", text: $viewModel.values.exactAddress)
                    Picker("City", selection: $viewModel.values.city) {
                        ForEach(City.allCases) { city in
                            Text(city.label).tag(city)
                        }
                    }
                } header: {
                    Text("Location")
                } footer: {
                    Text("Court name is public and shown on the feed. Exact address is private — only approved players see it.")
                }

                Section("Capacity & visibility") {
                    TextField("Capacity (blank = unlimited)", text: $viewModel.values.capacityText)
                        .keyboardType(.numberPad)
                    Picker("Visibility", selection: $viewModel.values.visibility) {
                        ForEach(RunVisibility.allCases) { visibility in
                            Text(visibility.displayName).tag(visibility)
                        }
                    }
                }

                Section {
                    Toggle("Approve everyone automatically", isOn: $viewModel.values.autoApprove)
                } footer: {
                    Text("Requests are accepted instantly instead of waiting on you.")
                }

                Section {
                    Button("Save as draft") {
                        viewModel.saveDraft(in: store)
                        toast.show("\(viewModel.values.title) saved as draft.")
                        dismiss()
                    }
                }
            }
            .navigationTitle(viewModel.heading)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publish") {
                        let title = viewModel.values.title.trimmingCharacters(in: .whitespacesAndNewlines)
                        viewModel.publish(in: store)
                        router.selectedTab = .hosting
                        toast.show("\(title.isEmpty ? "Untitled run" : title) published.")
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
