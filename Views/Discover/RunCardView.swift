import SwiftUI

/// Discover's run card — gradient banner + date chip + status badge, title, when/where, host
/// row, spots remaining. Ported field-for-field from the web's `.card` markup.
///
/// The banner/title/meta block is one tap target that opens Event Detail; the host avatar+name
/// is a second, independent tap target (`PersonLinkView`) that opens the host's profile — kept
/// as two separate `Button`s side-by-side rather than one nested inside the other's label, since
/// nested `Button`s inside a shared `Button` label have unreliable hit-testing in SwiftUI.
struct RunCardView: View {
    let run: Run

    @Environment(RunStore.self) private var store
    @Environment(\.navigate) private var navigate

    private var action: ViewerAction { store.viewerAction(for: run) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                navigate(.runDetail(run.id))
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    banner
                    VStack(alignment: .leading, spacing: 2) {
                        Text(run.title)
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Text(RunFormatting.cardWhen(run))
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
                Text(RunFormatting.monthAbbreviation(run))
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1)
                Text(RunFormatting.dayNumber(run))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .padding(10)

            if let badge = StatusBadgeView(viewerAction: action) {
                badge
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(10)
            }
        }
    }

    private var footer: some View {
        HStack {
            if let host = store.profile(run.hostId) {
                PersonLinkView(user: host, avatarSize: 24)
            }
            Spacer(minLength: 8)
            Text(RunFormatting.spotsText(run))
                .font(.system(size: 12.5, weight: run.isFull ? .semibold : .regular))
                .foregroundStyle(run.isFull ? Theme.Status.declinedFg : Theme.textTertiary)
        }
    }
}
