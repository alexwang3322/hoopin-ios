import SwiftUI
import ClerkKit

/// Discover is public. My Runs and Hosting prompt guests to sign in; Account also requires a
/// session before showing personal content.
struct AccountTabRootView: View {
    @Environment(Clerk.self) private var clerk

    var body: some View {
        if let user = clerk.user {
            AccountView().id(user.id)
        } else {
            AccountSignInPromptView()
        }
    }
}

/// Shown in place of the Account tab's content for a guest. Requests the app's single sign-in
/// sheet on each visit; RootView returns to Discover if it is dismissed while still signed out.
private struct AccountSignInPromptView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(Theme.accent)
            Text("Sign in required")
                .font(.title2.bold())
            Text("Sign in to manage your account.")
                .foregroundStyle(Theme.textSecondary)
            Button("Sign in") { router.showingSignIn = true }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .navigationTitle("Account")
        .onAppear {
            if router.selectedTab == .account { router.showingSignIn = true }
        }
    }
}
