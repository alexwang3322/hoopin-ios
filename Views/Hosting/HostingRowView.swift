import SwiftUI

/// One backend-sourced row in Hosting — thumbnail, title, and run state.
struct HostingRowView: View {
    let run: LiveRun

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: run.gradientStartHex), Color(hex: run.gradientEndHex)],
                                      startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(run.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                    if run.isDraft {
                        Text("DRAFT")
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(Theme.textTertiary)
                            .padding(.horizontal, 5).padding(.vertical, 1)
                            .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(Theme.borderSecondary))
                    }
                    if run.isCancelled {
                        Text("CANCELLED")
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(Theme.Status.declinedFg)
                            .padding(.horizontal, 5).padding(.vertical, 1)
                            .background(Theme.Status.declinedBg)
                            .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(Theme.Status.declinedRing))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    if !run.isDraft && !run.isCancelled && run.isFinished {
                        Text("FINISHED")
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(0.8)
                            .foregroundStyle(Theme.textTertiary)
                            .padding(.horizontal, 5).padding(.vertical, 1)
                            .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(Theme.borderSecondary))
                    }
                }
                Text(metaText)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textTertiary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Theme.border, lineWidth: 1))
    }

    private var metaText: String {
        if run.isDraft {
            return "\(LiveRunFormatting.shortWhen(startsAt: run.startsAt, endsAt: run.endsAt, timezoneID: run.timezoneID)) · \(run.goingCount) going"
        }
        if let capacity = run.capacity {
            return "\(LiveRunFormatting.shortWhen(startsAt: run.startsAt, endsAt: run.endsAt, timezoneID: run.timezoneID)) · \(run.goingCount) going of \(capacity)"
        }
        return "\(LiveRunFormatting.shortWhen(startsAt: run.startsAt, endsAt: run.endsAt, timezoneID: run.timezoneID)) · \(run.goingCount) going"
    }
}
