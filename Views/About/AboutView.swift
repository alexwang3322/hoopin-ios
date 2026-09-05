import SwiftUI

struct AboutView: View {
    var body: some View {
        LegalPageView(
            title: "About Hoopin",
            intro: "Pickup basketball, organized.",
            sections: [
                .init(body: "Hoopin is a simple way to find and host pickup basketball runs. Instead of a group chat that goes stale or a regular run that's hard for new people to find, hosts post a run once — time, court, format, and capacity — and players request to play."),
                .init(title: "How it works.", body: "Browse runs near you on Discover, or host your own from \"Host a run.\" Players send a request to join; hosts approve or decline. Once you're approved, the exact address unlocks — courts stay unlisted publicly so hosts control who shows up."),
                .init(title: "Who it's for.", body: "Regulars who want an easier way to fill out their weekly run, and anyone looking to find a game without already knowing a crew."),
                .init(title: "Where we are.", body: "Hoopin is early — we're still building out the basics and shipping fixes and features quickly. If something's confusing, missing, or plain broken, we want to hear about it. Contact information to be added."),
            ]
        )
    }
}
