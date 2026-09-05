import SwiftUI

struct PrivacyView: View {
    var body: some View {
        LegalPageView(
            title: "Privacy Policy",
            intro: "What we collect, why, and how it's shared — in plain language.",
            sections: [
                .init(title: "Account & identity data.", body: "Depending on how you sign up, this includes your name, email address, or phone number. We use this to create your Hoopin account and to show your name/initials to other users on runs you host or join."),
                .init(title: "Profile data.", body: "Your bio and any other profile fields you fill in are stored so they can be shown on your public profile within the app."),
                .init(title: "Run & request data.", body: "When you host a run, we store what you enter — title, description, schedule, venue name, exact address, capacity, and visibility. When you request to join a run, we store your message and the request's status. A run's exact address is only shown to the host and to requesters the host has approved."),
                .init(title: "How we share data.", body: "We don't sell your data. A run's public details (title, time, venue name, host, going count) are visible to anyone browsing Hoopin unless the host marks it private. Your exact address on a run you host is only ever shown to you and to players you've approved."),
                .init(title: "Data retention.", body: "We keep your account, run, and request data for as long as your account is active. If you delete your account, we remove your profile data; runs you hosted or requests you made may be retained in an anonymized form to keep other users' history intact."),
                .init(title: "Your rights.", body: "You can view and edit your profile in the Account tab at any time. To request deletion of your account or data, contact information to be added."),
                .init(title: "Children's privacy.", body: "Hoopin isn't directed at children, and we don't knowingly collect data from anyone under 13."),
                .init(title: "Changes to this policy.", body: "We may update this policy as the product changes."),
                .init(title: "Contact.", body: "Contact information to be added."),
            ]
        )
    }
}
