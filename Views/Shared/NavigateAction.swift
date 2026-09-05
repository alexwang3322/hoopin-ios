import SwiftUI

/// Lets any nested view push an `AppRoute` onto the current tab's own `NavigationStack` without
/// owning that stack's path itself — each tab root sets this in `.environment(\.navigate, ...)`.
struct NavigateAction {
    let action: (AppRoute) -> Void
    func callAsFunction(_ route: AppRoute) { action(route) }
}

private struct NavigateKey: EnvironmentKey {
    static let defaultValue = NavigateAction(action: { _ in })
}

extension EnvironmentValues {
    var navigate: NavigateAction {
        get { self[NavigateKey.self] }
        set { self[NavigateKey.self] = newValue }
    }
}

/// Shared destination resolver used by every tab's `.navigationDestination(for: AppRoute.self)`.
struct AppRouteDestinationView: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .runDetail(let id):
            EventDetailView(runId: id)
        case .profile(let id):
            ProfileView(userId: id)
        }
    }
}
