import Foundation
import Observation

enum AppTab: Hashable {
    case discover
    case myRuns
    case hosting
    case account
}

/// Cross-tab navigation destinations, pushed onto whichever tab's own `NavigationStack` the
/// user is currently in.
enum AppRoute: Hashable {
    case runDetail(String)
    case profile(String)
    /// A backend-sourced run, read-only — distinct from `runDetail`, which stays on RunStore's
    /// mock data. See LiveEventDetailView's note.
    case liveRunDetail(String)
}

/// Owns which tab is selected. Screens switch tabs directly (e.g. tapping your own avatar routes
/// to the Account tab, matching the web's `CURRENT_USER_ID` check in its delegated click handler)
/// while in-tab pushes are handled by each tab's own `NavigationStack` via the `navigate`
/// environment action (see `NavigateAction.swift`).
@Observable
final class AppRouter {
    var selectedTab: AppTab = .discover
    var runsRevision = 0
    var showingSignIn = false
}
