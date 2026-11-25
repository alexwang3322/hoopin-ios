import SwiftUI
import ClerkKit

/// "Any avatar+name mention of a person, anywhere, links to their profile" — the web prototype's
/// own comment on `.person-link`. Every host row, requester row, roster row, and card footer in
/// this app routes through this one component instead of hand-wiring navigation per place a
/// person is mentioned. Tapping the current viewer switches to the Account tab instead of
/// pushing a read-only Profile screen (mirrors the original JS's `CURRENT_USER_ID` check).
struct PersonLinkView: View {
    let user: UserSummary
    var subtitle: String?
    var avatarSize: CGFloat = 32

    @Environment(Clerk.self) private var clerk
    @Environment(AppRouter.self) private var router
    @Environment(\.navigate) private var navigate

    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: 10) {
                AvatarView(initials: user.initials, colorHex: user.avatarColorHex,
                           size: avatarSize, fontSize: avatarSize * 0.38)
                VStack(alignment: .leading, spacing: 1) {
                    Text(user.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Theme.textTertiary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func handleTap() {
        if user.id == clerk.user?.id {
            router.selectedTab = .account
        } else {
            navigate(.profile(user.id))
        }
    }
}
