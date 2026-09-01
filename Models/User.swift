import Foundation

/// Mirrors API_CONTRACT.md's `UserSummary` — public profile, safe to embed anywhere.
/// `avatarColorHex` is an app-local addition: the contract has no notion of avatar color
/// (the web prototype hand-picks a hex/gradient per fixture rather than deriving it), so it's
/// carried here directly rather than in a separate lookup table.
struct UserSummary: Identifiable, Hashable {
    let id: String
    var name: String
    var initials: String
    var bio: String?
    var avatarColorHex: String
}
