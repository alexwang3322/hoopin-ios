import Foundation

/// The web's Account screen edits four fields (location, gender, position) that live outside
/// API_CONTRACT.md's `UserSummary` — this wraps the shared `UserSummary` with those app-local extras.
struct AccountProfile: Hashable {
    var user: UserSummary
    var location: AccountLocation
    var gender: Gender
    var position: PlayerPosition
}
