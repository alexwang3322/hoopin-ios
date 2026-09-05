import SwiftUI
import ClerkKit

@main
struct HoopinApp: App {
    init() {
        Clerk.configure(publishableKey: Config.clerkPublishableKey)
    }

    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .environment(Clerk.shared)
        }
    }
}
