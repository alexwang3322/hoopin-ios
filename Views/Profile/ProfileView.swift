import SwiftUI

/// Public profile fetched by user id, including for signed-out visitors.
struct ProfileView: View {
    let userId: String

    @State private var user: UserSummary?
    @State private var isLoading = true
    @State private var loadedUserId: String?

    var body: some View {
        Group {
            if loadedUserId != userId || isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let user {
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
        .task(id: userId) {
            user = nil
            loadedUserId = nil
            isLoading = true
            do {
                let wire = try await LiveApiClient.getUser(id: userId)
                guard !Task.isCancelled else { return }
                user = LiveMappers.toUserSummary(wire)
            } catch {
                guard !Task.isCancelled else { return }
                user = nil
            }
            loadedUserId = userId
            isLoading = false
        }
    }
}
