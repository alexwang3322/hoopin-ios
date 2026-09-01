import SwiftUI

/// Circular initials avatar — every avatar in the web prototype is a solid/gradient circle with
/// centered initials text, never a photo (no image upload endpoints exist per API_CONTRACT.md §6).
struct AvatarView: View {
    let initials: String
    let colorHex: String
    var size: CGFloat = 32
    var fontSize: CGFloat = 12

    var body: some View {
        Circle()
            .fill(Color(hex: colorHex))
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            )
    }
}
