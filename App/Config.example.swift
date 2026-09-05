import Foundation

/// Copy to Config.swift (gitignored) with the real value. Clerk Dashboard -> API Keys ->
/// Publishable key — safe to commit by design (it ships in the app binary either way), but kept
/// out of git anyway to mirror frontend/.env.local's pattern for the same key.
enum Config {
    static let clerkPublishableKey = ""
}
