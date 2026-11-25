import Foundation
import Observation

enum RunFormError: LocalizedError {
    case invalid(String)

    var errorDescription: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}

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
    var city: City = .sd
    var capacityText: String = "10"
    var visibility: RunVisibility = .publicVisibility
    var autoApprove: Bool = true

    func toWireRequest(publish: Bool) throws -> WireCreateRunRequest {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let venue = venueName.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = exactAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let zoneID = timezoneID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw RunFormError.invalid("Enter a title.") }
        guard !venue.isEmpty else { throw RunFormError.invalid("Enter a court name.") }
        guard !address.isEmpty else { throw RunFormError.invalid("Enter an exact address.") }
        guard TimeZone(identifier: zoneID) != nil else {
            throw RunFormError.invalid("Enter a valid IANA timezone, such as America/Los_Angeles.")
        }

        let capacityInput = capacityText.trimmingCharacters(in: .whitespacesAndNewlines)
        let capacity: Int?
        if capacityInput.isEmpty {
            capacity = nil
        } else if let value = Int(capacityInput), value > 0 {
            capacity = value
        } else {
            throw RunFormError.invalid("Capacity must be a positive whole number or blank.")
        }

        let calendar = Calendar.current
        let day = calendar.dateComponents([.year, .month, .day], from: date)
        let start = calendar.dateComponents([.hour, .minute], from: startTime)
        let end = calendar.dateComponents([.hour, .minute], from: endTime)
        guard let year = day.year, let month = day.month, let dayNumber = day.day,
              let startHour = start.hour, let startMinute = start.minute,
              let endHour = end.hour, let endMinute = end.minute else {
            throw RunFormError.invalid("Choose a date and start and end times.")
        }
        if publish && (endHour * 60 + endMinute <= startHour * 60 + startMinute) {
            throw RunFormError.invalid("End time must be after start time.")
        }

        return WireCreateRunRequest(
            title: title, description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            date: String(format: "%04d-%02d-%02d", year, month, dayNumber),
            startTime: String(format: "%02d:%02d", startHour, startMinute),
            endTime: String(format: "%02d:%02d", endHour, endMinute),
            timezone: zoneID, format: format.rawValue, venueName: venue, exactAddress: address,
            city: city.rawValue, capacity: capacity, visibility: visibility.rawValue,
            autoApprove: autoApprove, publish: publish
        )
    }

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
            city: city,
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
        values.city = run.city
        values.capacityText = run.capacity.map(String.init) ?? ""
        values.visibility = run.visibility
        values.autoApprove = run.autoApprove
        return values
    }

    static func from(run: LiveRunDetail) -> CreateRunFormValues {
        var values = CreateRunFormValues()
        let zone = TimeZone(identifier: run.timezoneID) ?? .current
        var runCalendar = Calendar(identifier: .gregorian)
        runCalendar.timeZone = zone
        let day = runCalendar.dateComponents([.year, .month, .day], from: run.startsAt)
        let start = runCalendar.dateComponents([.hour, .minute], from: run.startsAt)
        let end = runCalendar.dateComponents([.hour, .minute], from: run.endsAt)
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())

        values.title = run.title
        values.description = run.description
        values.date = Calendar.current.date(from: DateComponents(year: day.year, month: day.month, day: day.day)) ?? run.startsAt
        values.startTime = Calendar.current.date(from: DateComponents(year: today.year, month: today.month, day: today.day,
                                                                     hour: start.hour, minute: start.minute)) ?? run.startsAt
        values.endTime = Calendar.current.date(from: DateComponents(year: today.year, month: today.month, day: today.day,
                                                                   hour: end.hour, minute: end.minute)) ?? run.endsAt
        values.timezoneID = run.timezoneID
        values.format = run.format
        values.venueName = run.venueName
        values.exactAddress = run.exactAddress ?? ""
        values.city = run.city
        values.capacityText = run.capacity.map(String.init) ?? ""
        values.visibility = run.visibility
        values.autoApprove = run.autoApprove
        return values
    }
}

/// Owns the Create/"Host a run" form's transient field state. `draftId` is non-nil when editing
/// a backend draft so saving or publishing updates that run in place.
@Observable
final class CreateRunFormViewModel {
    var values: CreateRunFormValues
    let draftId: String?
    let isEditingDraft: Bool

    init(editingDraft run: LiveRunDetail? = nil) {
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

}
