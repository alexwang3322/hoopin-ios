import SwiftUI

/// One row in the host-side "Requests to play" list — requester avatar/name/timestamp, their
/// optional message, and Approve/Decline actions. Ported from the web's `.request-card`.
struct RequestCardView: View {
    let request: JoinRequest
    let requester: UserSummary
    let onApprove: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                AvatarView(initials: requester.initials, colorHex: requester.avatarColorHex, size: 40, fontSize: 15)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(requester.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                        Text(RelativeTime.ago(from: request.createdAt))
                            .font(.caption2)
                            .foregroundStyle(Theme.textTertiary)
                    }
                    if let bio = requester.bio {
                        Text(bio)
                            .font(.caption)
                            .foregroundStyle(Theme.textTertiary)
                    }
                }
            }

            if let message = request.message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack(spacing: 8) {
                Button("Approve", action: onApprove)
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)

                Button("Decline", role: .destructive, action: onDecline)
                    .buttonStyle(.bordered)
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Theme.border, lineWidth: 1)
        )
    }
}
