import SwiftUI

struct SecurityView: View {
    var body: some View {
        LegalPageView(
            title: "Security",
            intro: "How we protect your account and data, and how to report a concern.",
            sections: [
                .init(title: "Authentication.", body: "Sign-in is handled by Clerk, a dedicated authentication provider — Hoopin never sees or stores your password. Sessions are verified before any account-specific data is returned."),
                .init(title: "Data in transit.", body: "All traffic between the app and our servers is encrypted (HTTPS/TLS)."),
                .init(title: "Access controls.", body: "A run's exact address is only ever included in a response to that run's host, or to a requester the host has explicitly approved — this is enforced server-side, not just hidden in the interface."),
                .init(title: "Infrastructure.", body: "Hoopin runs on Cloudflare's platform (Workers and D1), which provides DDoS protection and encryption at rest for stored data."),
                .init(title: "What you can do.", body: "Use a strong, unique password (or a passkey/social sign-in) for your Hoopin account, and don't share your sign-in link or session with anyone else."),
                .init(title: "Reporting a vulnerability.", body: "If you believe you've found a security issue in Hoopin, please report it responsibly rather than exploiting it or disclosing it publicly. Contact information to be added."),
            ]
        )
    }
}
