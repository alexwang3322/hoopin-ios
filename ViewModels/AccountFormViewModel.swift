import Foundation
import Observation

/// Editable account fields loaded from and saved to the authenticated backend profile.
@Observable
final class AccountFormViewModel {
    var name: String
    var bio: String
    var location: City
    var gender: Gender
    var position: PlayerPosition

    init() {
        name = ""
        bio = ""
        location = .sd
        gender = .preferNotToSay
        position = .flexible
    }

    var displayInitials: String { initials(from: name) }

    func initials(from name: String) -> String {
        let parts = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .filter { !$0.isEmpty }
        if parts.isEmpty { return "" }
        if parts.count == 1 { return String(parts[0].prefix(2)).uppercased() }
        let first = parts.first!.first.map(String.init) ?? ""
        let last = parts.last!.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    func apply(_ profile: WireAccountProfile) throws {
        guard let location = City(rawValue: profile.location ?? City.sd.rawValue),
              let gender = Gender(rawValue: profile.gender ?? Gender.preferNotToSay.rawValue),
              let position = PlayerPosition(rawValue: profile.position ?? PlayerPosition.flexible.rawValue) else {
            throw AccountProfileError.unsupportedPreference
        }
        name = profile.name
        bio = profile.bio ?? ""
        self.location = location
        self.gender = gender
        self.position = position
    }

    var updateRequest: WireUpdateAccountRequest {
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        return WireUpdateAccountRequest(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            bio: trimmedBio.isEmpty ? nil : trimmedBio,
            location: location.rawValue,
            gender: gender.rawValue,
            position: position.rawValue
        )
    }
}

enum AccountProfileError: Error {
    case unsupportedPreference
    case incorrectAccount
}
