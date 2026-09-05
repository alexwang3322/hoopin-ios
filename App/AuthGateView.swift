import SwiftUI
import ClerkKit
import ClerkKitUI

/// Gates the whole app behind a real Clerk session — the simplest correct integration given
/// RunStore's mock data has no concept of a signed-out viewer at all (every hosting/join-request
/// interaction is anchored to the "Jamie Tran" story regardless of who's authenticated; see
/// RunStore.currentUserId). Signing in via Clerk doesn't change what mock data shows — it's a
/// real, working auth flow layered on top of a still-fully-mock app, matching how far this port
/// goes for now (mobile-ios isn't wired to backend/'s live API).
struct AuthGateView: View {
    @Environment(Clerk.self) private var clerk

    var body: some View {
        if clerk.user != nil {
            RootView()
        } else {
            WelcomeView()
        }
    }
}

private struct WelcomeView: View {
    @State private var authIsPresented = true

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "basketball.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.accent)
            Text("Hoopin")
                .font(.largeTitle.bold())
            Text("Sign in to find and host pickup runs.")
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Button("Sign in") { authIsPresented = true }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .sheet(isPresented: $authIsPresented) {
            AuthView()
        }
    }
}
