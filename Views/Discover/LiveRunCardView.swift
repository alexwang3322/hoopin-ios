import SwiftUI

/// Read-only card for a backend-sourced run — a separate view from `RunCardView` (mock) since
/// this reads `viewerStatus`/`host` directly off the fetched object, no `RunStore` lookup at all.
struct LiveRunCardView: View {
    let run: LiveRun
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 12) {
                    banner
                    VStack(alignment: .leading, spacing: 2) {
                        Text(run.title)
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Text(LiveRunFormatting.cardWhen(startsAt: run.startsAt, endsAt: run.endsAt,
                                                         timezoneID: run.timezoneID, format: run.format))
                            .font(.system(size: 13.5))
                            .foregroundStyle(Theme.textSecondary)
                        Text(run.venueName)
                            .font(.system(size: 13.5))
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .buttonStyle(.plain)

            footer
                .padding(16)
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Theme.border, lineWidth: 1)
        )
    }

    private var banner: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: [Color(hex: run.gradientStartHex), Color(hex: run.gradientEndHex)],
                            startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 110)

            VStack(spacing: 1) {
                Text(LiveRunFormatting.monthAbbreviation(startsAt: run.startsAt, timezoneID: run.timezoneID))
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1)
                Text(LiveRunFormatting.dayNumber(startsAt: run.startsAt, timezoneID: run.timezoneID))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .padding(10)

            if run.isCancelled {
                StatusBadgeView(text: "Cancelled", foreground: Theme.Status.declinedFg,
                                 background: Theme.Status.declinedBg, ring: Theme.Status.declinedRing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(10)
            } else if !run.isDraft && run.isFinished {
                StatusBadgeView(text: "Finished", foreground: Theme.textTertiary,
                                 background: Theme.surfaceSecondary, ring: Theme.borderSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(10)
            }
        }
    }

    private var footer: some View {
        HStack {
            PersonLinkView(user: run.host, avatarSize: 24)
            Spacer(minLength: 8)
            Text(spotsText)
                .font(.system(size: 12.5, weight: run.isFull ? .semibold : .regular))
                .foregroundStyle(run.isFull ? Theme.Status.declinedFg : Theme.textTertiary)
        }
    }

    private var spotsText: String {
        guard let capacity = run.capacity else { return "\(run.goingCount) going" }
        if run.isFull { return "Full" }
        return "\(run.goingCount)/\(capacity) · \(capacity - run.goingCount) open"
    }
}
