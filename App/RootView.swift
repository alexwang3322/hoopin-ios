import SwiftUI
import ClerkKit
import ClerkKitUI

/// Wraps one tab's root screen in its own `NavigationStack`, publishing a `navigate` environment
/// action so any descendant can push an `AppRoute` (Event Detail, Profile, Disclaimer) onto this
/// tab's stack without owning the path itself.
struct TabRootStack<Content: View>: View {
    @State private var path = NavigationPath()
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationStack(path: $path) {
            content()
                .navigationDestination(for: AppRoute.self) { route in
                    AppRouteDestinationView(route: route)
                }
        }
        .environment(\.navigate, NavigateAction { path.append($0) })
    }
}

/// Four tabs — Discover, My Runs, Hosting, Account — matching the web's persistent top bar nav
/// plus its always-present account chip, which becomes a fourth tab here so it's reachable from
/// anywhere (SwiftUI has no equivalent to a sticky cross-screen header chip).
struct RootView: View {
    @Environment(Clerk.self) private var clerk
    @State private var store = RunStore()
    @State private var toast = ToastCenter()
    @State private var router = AppRouter()

    var body: some View {
        @Bindable var router = router
        // Drop navigation paths and presented sheets when the active account changes.
        let sessionKey = clerk.user?.id ?? "guest"

        TabView(selection: $router.selectedTab) {
            TabRootStack { DiscoverView() }
                .id(sessionKey)
                .tabItem { Label("Discover", systemImage: "sportscourt") }
                .tag(AppTab.discover)

            TabRootStack { MyRunsView() }
                .id(sessionKey)
                .tabItem { Label("My Runs", systemImage: "figure.basketball") }
                .tag(AppTab.myRuns)

            TabRootStack { HostingView() }
                .id(sessionKey)
                .tabItem { Label("Hosting", systemImage: "person.3.fill") }
                .tag(AppTab.hosting)

            TabRootStack { AccountTabRootView() }
                .id(sessionKey)
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
                .tag(AppTab.account)
        }
        .tint(Theme.accent)
        .sheet(isPresented: $router.showingSignIn, onDismiss: {
            if clerk.user == nil && router.selectedTab == .account {
                router.selectedTab = .discover
            }
        }) {
            AuthView()
        }
        .overlay(alignment: .bottom) { ToastOverlay() }
        .environment(store)
        .environment(toast)
        .environment(router)
    }
}
