import SwiftUI

struct TermsView: View {
    var body: some View {
        LegalPageView(
            title: "Terms of Service",
            intro: "These terms govern your use of Hoopin. By creating an account or using the app, you agree to them.",
            sections: [
                .init(title: "1. The service.", body: "Hoopin lets users create (\"host\") and join (\"request to play\") pickup basketball runs. We provide the platform that connects hosts and players — we don't organize, staff, insure, or supervise any run ourselves."),
                .init(title: "2. Accounts.", body: "You need an account to host a run, request to join one, or see a run's exact address. You're responsible for keeping your account credentials secure and for all activity under your account."),
                .init(title: "3. Hosting and joining runs.", body: "As a host, you're responsible for the accuracy of what you post (time, location, format, capacity) and for how you manage requests to join. As a requester, you're responsible for showing up as agreed or withdrawing your request if your plans change. Hoopin doesn't guarantee that any run will happen or that a host will approve your request."),
                .init(title: "4. Acceptable use.", body: "Don't use Hoopin to harass, threaten, or discriminate against anyone; post false, misleading, or unlawful content; impersonate another person; or attempt to bypass any access control (for example, viewing an exact address you weren't approved for)."),
                .init(title: "5. Content you post.", body: "You keep ownership of the run descriptions, messages, and profile content you post, but you grant Hoopin a license to display it within the app so the product can function. See the Disclaimer for more on user-generated content."),
                .init(title: "6. Assumption of risk and liability.", body: "Basketball and organizing in-person meetups carry inherent risk. Full detail on assumption of risk and limitation of liability is in the Disclaimer & Liability Waiver, which is part of these Terms."),
                .init(title: "7. Termination.", body: "You may stop using Hoopin and delete your account at any time. We may suspend or terminate your access if you violate these Terms."),
                .init(title: "8. Changes to these terms.", body: "We may update these Terms as the product changes. Continued use of Hoopin after an update means you accept the revised Terms."),
                .init(title: "9. Governing law.", body: "To be finalized."),
                .init(title: "10. Contact.", body: "Contact information to be added."),
            ]
        )
    }
}
