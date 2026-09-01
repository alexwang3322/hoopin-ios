import SwiftUI

/// One row in My Runs — thumbnail, title, when, relative "requested" timestamp, status badge,
/// and a decline-reason callout when declined. Ported from the web's `.req-row`.
struct MyRunRowView: View {
    let request: JoinRequest
    let run: Run

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: run.gradientStartHex), Color(hex: run.gradientEndHex)],
                                      startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(run.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(RunFormatting.shortWhen(run))
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
                Text("Requested \(RelativeTime.ago(from: request.createdAt))")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)

                if request.status == .declined, let reason = request.declineReason {
                    Text("Host said: \(reason)")
                        .font(.system(size: 13.5))
                        .foregroundStyle(Theme.Status.declinedFg)
                        .padding(10)
                        .background(Theme.Status.declinedBg)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 4)
                }
            }

            Spacer(minLength: 8)
            StatusBadgeView(requestStatus: request.status)
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Theme.border, lineWidth: 1))
    }
}
