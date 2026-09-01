import SwiftUI

/// Read-only public profile — every avatar+name mention in the app links here via
/// `PersonLinkView`, sourced from the shared profile directory in `RunStore`.
struct ProfileView: View {
    let userId: String

    @Environment(RunStore.self) private var store

    var body: some View {
        if let user = store.profile(userId) {
            VStack(spacing: 12) {
                AvatarView(initials: user.initials, colorHex: user.avatarColorHex, size: 72, fontSize: 26)
                VStack(spacing: 4) {
                    Text(user.name)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Theme.ink)
                    if let bio = user.bio {
                        Text(bio)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Theme.background)
            .navigationTitle("Player")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            ContentUnavailableView("Player not found", systemImage: "person.crop.circle.badge.questionmark")
        }
    }
}
