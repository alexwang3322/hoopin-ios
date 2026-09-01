import SwiftUI

struct StatusBadgeView: View {
    let text: String
    let foreground: Color
    let background: Color
    let ring: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(background)
            )
            .overlay(
                Capsule().strokeBorder(ring, lineWidth: 1)
            )
    }
}

extension StatusBadgeView {
    init?(viewerAction: ViewerAction) {
        guard let label = viewerAction.badgeLabel else { return nil }
        self.init(text: label, foreground: viewerAction.badgeForeground,
                   background: viewerAction.badgeBackground, ring: viewerAction.badgeRing)
    }

    init(requestStatus: JoinRequestStatus) {
        self.init(text: requestStatus.badgeLabel, foreground: requestStatus.badgeForeground,
                   background: requestStatus.badgeBackground, ring: Theme.borderSecondary)
    }
}
