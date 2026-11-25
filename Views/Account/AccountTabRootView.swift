import SwiftUI
import ClerkKit
import ClerkKitUI

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

/// Shown in place of the Account tab's content for a guest. Auto-presents Clerk's sign-in sheet
/// on every visit while signed out; backing out of the sheet without completing sign-in returns
/// to Discover ("home") rather than leaving the guest stranded on this empty tab.
private struct AccountSignInPromptView: View {
    @Environment(Clerk.self) private var clerk
    @Environment(AppRouter.self) private var router
    @State private var authIsPresented = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(Theme.accent)
            Text("Sign in required")
                .font(.title2.bold())
            Text("Sign in to manage your account.")
                .foregroundStyle(Theme.textSecondary)
            Button("Sign in") { authIsPresented = true }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .navigationTitle("Account")
        .onAppear {
            if router.selectedTab == .account { authIsPresented = true }
        }
        .sheet(isPresented: $authIsPresented, onDismiss: returnHomeIfStillSignedOut) {
            AuthView()
        }
    }

    private func returnHomeIfStillSignedOut() {
        if clerk.user == nil {
            router.selectedTab = .discover
        }
    }
}
