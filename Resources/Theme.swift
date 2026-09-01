import SwiftUI
import UIKit

extension Color {
    /// Hex-string initializer, e.g. `Color(hex: "#E8631A")` or `Color(hex: "E8631A")`.
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let r = Double((value & 0xFF0000) >> 16) / 255
        let g = Double((value & 0x00FF00) >> 8) / 255
        let b = Double(value & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }

    /// A color that swaps between a light and dark hex value with the trait environment,
    /// mirroring the web's `@media (prefers-color-scheme: dark)` token overrides.
    static func dynamic(light: String, dark: String) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light))
        })
    }
}

/// Ports the CSS custom-property design tokens from `html/index.html`'s `:root` (light) and its
/// `[data-theme="dark"]` / `prefers-color-scheme: dark` block (dark) — no asset catalog needed.
enum Theme {
    static let background = Color.dynamic(light: "FBF6EF", dark: "15120E")
    static let surface = Color.dynamic(light: "FFFDF9", dark: "1E1912")
    static let surfaceSecondary = Color.dynamic(light: "F4EBDD", dark: "251F17")
    static let ink = Color.dynamic(light: "1B1712", dark: "F3ECE2")
    static let textSecondary = Color.dynamic(light: "6B6155", dark: "B7AA96")
    static let textTertiary = Color.dynamic(light: "9C9280", dark: "85795F")
    static let border = Color.dynamic(light: "E4D9C8", dark: "362E24")
    static let borderSecondary = Color.dynamic(light: "D8CAB2", dark: "463B2D")
    static let accent = Color.dynamic(light: "E8631A", dark: "F1793C")
    static let accentInk = Color.dynamic(light: "FFF8F1", dark: "1B1712")
    static let hardwood = Color.dynamic(light: "C98A43", dark: "D9A05C")

    enum Status {
        static let pendingBg = Color.dynamic(light: "FBEEDA", dark: "332A16")
        static let pendingFg = Color.dynamic(light: "8A5A14", dark: "E3B871")
        static let pendingRing = Color.dynamic(light: "F0D9AE", dark: "4A3B1D")

        static let playingBg = Color.dynamic(light: "E1F3E7", dark: "17301F")
        static let playingFg = Color.dynamic(light: "1F7A4D", dark: "79D69C")
        static let playingRing = Color.dynamic(light: "BFE4CB", dark: "274634")

        static let declinedBg = Color.dynamic(light: "FBE6E2", dark: "331D18")
        static let declinedFg = Color.dynamic(light: "B33A2E", dark: "E39184")
        static let declinedRing = Color.dynamic(light: "F2C9C0", dark: "4A2A22")

        static let hostBg = Color.dynamic(light: "FDE9DA", dark: "3A2413")
        static let hostFg = Color.dynamic(light: "B84E12", dark: "F0A264")
        static let hostRing = Color.dynamic(light: "F4C79E", dark: "52341C")
    }
}

extension ViewerAction {
    /// Badge label — mirrors the web's `BADGE_LABEL` map. `canRequest` never shows a badge
    /// (the original hides it entirely); `full` shows one even though the original JS's
    /// `BADGE_CLASS`/`BADGE_LABEL` maps never actually covered that branch.
    var badgeLabel: String? {
        switch self {
        case .canRequest: return nil
        case .host: return "Host"
        case .pending: return "Pending"
        case .approved: return "Playing"
        case .declined: return "Declined"
        case .full: return "Full"
        }
    }

    var badgeForeground: Color {
        switch self {
        case .host: return Theme.Status.hostFg
        case .pending: return Theme.Status.pendingFg
        case .approved: return Theme.Status.playingFg
        case .declined, .full: return Theme.Status.declinedFg
        case .canRequest: return Theme.textSecondary
        }
    }

    var badgeBackground: Color {
        switch self {
        case .host: return Theme.Status.hostBg
        case .pending: return Theme.Status.pendingBg
        case .approved: return Theme.Status.playingBg
        case .declined, .full: return Theme.Status.declinedBg
        case .canRequest: return Theme.surfaceSecondary
        }
    }

    var badgeRing: Color {
        switch self {
        case .host: return Theme.Status.hostRing
        case .pending: return Theme.Status.pendingRing
        case .approved: return Theme.Status.playingRing
        case .declined, .full: return Theme.Status.declinedRing
        case .canRequest: return Theme.borderSecondary
        }
    }
}

extension JoinRequestStatus {
    var badgeLabel: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Playing"
        case .declined: return "Declined"
        case .withdrawn: return "Withdrawn"
        }
    }

    var badgeForeground: Color {
        switch self {
        case .pending: return Theme.Status.pendingFg
        case .approved: return Theme.Status.playingFg
        case .declined: return Theme.Status.declinedFg
        case .withdrawn: return Theme.textTertiary
        }
    }

    var badgeBackground: Color {
        switch self {
        case .pending: return Theme.Status.pendingBg
        case .approved: return Theme.Status.playingBg
        case .declined: return Theme.Status.declinedBg
        case .withdrawn: return Theme.surfaceSecondary
        }
    }
}
