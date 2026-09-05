import Foundation
import Observation

/// Owns the Account screen's editable field state, seeded from the store's current profile and
/// written back on Save — matches the web's `saveAccountBtn` handler (recompute initials from
/// the edited name, update the shared profile so every other mention of "you" stays in sync).
@Observable
final class AccountFormViewModel {
    var name: String
    var bio: String
    var location: City
    var gender: Gender
    var position: PlayerPosition

    init(profile: AccountProfile) {
        name = profile.user.name
        bio = profile.user.bio ?? ""
        location = profile.location
        gender = profile.gender
        position = profile.position
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

    func save(in store: RunStore) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? "Hooper" : trimmedName
        var user = store.currentUser
        user.name = finalName
        user.initials = initials(from: finalName)
        user.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines)

        let updated = AccountProfile(user: user, location: location, gender: gender, position: position)
        store.updateAccount(updated)
    }
}
