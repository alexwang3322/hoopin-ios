import Foundation
import Observation

/// The Create/"Host a run" form's field values, decoupled from `Run` so half-filled draft state
/// (blank venue/address/capacity) is representable without optionals leaking into the read model.
struct CreateRunFormValues {
    var title: String = ""
    var description: String = ""
    var date: Date = Date()
    var startTime: Date = Date()
    var endTime: Date = Date()
    var timezoneID: String = TimeZone.current.identifier
    var format: RunFormat = .fiveVFiveFullCourt
    var venueName: String = ""
    var exactAddress: String = ""
    var capacityText: String = "10"
    var visibility: RunVisibility = .publicVisibility
    var autoApprove: Bool = true

    /// Combines the separate Date/Start/End fields into zoned start/end instants, mirroring how
    /// the web's server-side contract combines `date` + `start_time` + `end_time` + `timezone`.
    func makeRun(id: String, hostId: String, isDraft: Bool, existingAttendeeIds: [String],
                 existingGoingCount: Int, gradientStart: String, gradientEnd: String) -> Run {
        let tz = TimeZone(identifier: timezoneID) ?? .current
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tz

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

        var startDC = dateComponents
        startDC.hour = startComponents.hour
        startDC.minute = startComponents.minute
        var endDC = dateComponents
        endDC.hour = endComponents.hour
        endDC.minute = endComponents.minute

        let startsAt = calendar.date(from: startDC) ?? date
        let endsAt = calendar.date(from: endDC) ?? startsAt

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedVenue = venueName.trimmingCharacters(in: .whitespacesAndNewlines)
        let capacity = Int(capacityText.trimmingCharacters(in: .whitespacesAndNewlines))

        return Run(
            id: id,
            title: trimmedTitle.isEmpty ? "Untitled run" : trimmedTitle,
            description: description,
            startsAt: startsAt,
            endsAt: endsAt,
            timezoneID: timezoneID,
            format: format,
            venueName: trimmedVenue.isEmpty ? "Venue TBD" : trimmedVenue,
            exactAddress: exactAddress,
            city: .sf,
            hostId: hostId,
            capacity: capacity,
            goingCount: existingGoingCount,
            isDraft: isDraft,
            visibility: visibility,
            autoApprove: autoApprove,
            attendeeIds: existingAttendeeIds,
            distanceMiles: 0,
            gradientStartHex: gradientStart,
            gradientEndHex: gradientEnd,
            createdAt: Date()
        )
    }

    static func from(run: Run) -> CreateRunFormValues {
        var values = CreateRunFormValues()
        values.title = run.title
        values.description = run.description
        values.date = run.startsAt
        values.startTime = run.startsAt
        values.endTime = run.endsAt
        values.timezoneID = run.timezoneID
        values.format = run.format
        values.venueName = run.venueName
        values.exactAddress = run.exactAddress
        values.capacityText = run.capacity.map(String.init) ?? ""
        values.visibility = run.visibility
        values.autoApprove = run.autoApprove
        return values
    }
}

/// Owns the Create/"Host a run" form's transient field state and delegates persistence to
/// `RunStore`. `draftId` is non-nil when editing an existing draft (publishing then updates that
/// draft in place instead of prepending a duplicate Hosting row).
@Observable
final class CreateRunFormViewModel {
    var values: CreateRunFormValues
    let draftId: String?
    let isEditingDraft: Bool

    init(editingDraft run: Run? = nil) {
        if let run {
            self.values = CreateRunFormValues.from(run: run)
            self.draftId = run.id
            self.isEditingDraft = true
        } else {
            self.values = CreateRunFormValues()
            self.draftId = nil
            self.isEditingDraft = false
        }
    }

    var heading: String { isEditingDraft ? "Edit draft" : "Host a run" }
    var subtitle: String {
        isEditingDraft
            ? "Finish filling this in, then publish when you're ready."
            : "You'll review each request to play before anyone gets the address."
    }

    @discardableResult
    func publish(in store: RunStore) -> String {
        store.publish(values, draftId: draftId)
    }

    func saveDraft(in store: RunStore) {
        store.saveDraft(values, draftId: draftId)
    }
}
