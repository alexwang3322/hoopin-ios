import Foundation

/// Wire-stable format key, mirrors `RunFormat` in API_CONTRACT.md.
enum RunFormat: String, Codable, CaseIterable, Identifiable {
    case fiveVFiveFullCourt = "5v5_full_court"
    case threeVThreeHalfCourt = "3v3_half_court"

    var id: String { rawValue }

    /// Display copy the host-a-run form's <select> used ("FE owns the label mapping" per API_CONTRACT.md).
    var displayName: String {
        switch self {
        case .fiveVFiveFullCourt: return "5v5 · Full court"
        case .threeVThreeHalfCourt: return "3v3 · Half court"
        }
    }

    var shortLabel: String {
        switch self {
        case .fiveVFiveFullCourt: return "5v5 full court"
        case .threeVThreeHalfCourt: return "3v3 half court"
        }
    }
}

enum RunVisibility: String, Codable, CaseIterable, Identifiable {
    case publicVisibility = "public"
    case privateVisibility = "private"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .publicVisibility: return "Public — listed in Discover"
        case .privateVisibility: return "Private — invite link only"
        }
    }
}

enum City: String, Codable, CaseIterable, Identifiable {
    case sf = "SF"
    case oak = "OAK"

    var id: String { rawValue }

    /// Cosmetic segmented control in the original prototype — never actually filters the feed.
    var label: String { rawValue }
}

/// The 7-branch action-panel state machine from Event Detail's sidebar (API_CONTRACT.md `ViewerAction`),
/// computed per (run, viewer). `signedOut` is omitted — this app has no sign-in flow, the viewer is
/// always logged in as Jamie Tran.
enum ViewerAction: String, Codable {
    case canRequest
    case host
    case pending
    case approved
    case declined
    case full
}

enum JoinRequestStatus: String, Codable {
    case pending
    case approved
    case declined
    case withdrawn
}

enum Gender: String, Codable, CaseIterable, Identifiable {
    case preferNotToSay = "Prefer not to say"
    case woman = "Woman"
    case man = "Man"
    case nonBinary = "Non-binary"

    var id: String { rawValue }
}

enum PlayerPosition: String, Codable, CaseIterable, Identifiable {
    case flexible = "Flexible"
    case pointGuard = "Point guard"
    case shootingGuard = "Shooting guard"
    case forward = "Forward"
    case center = "Center"

    var id: String { rawValue }
}

enum AccountLocation: String, Codable, CaseIterable, Identifiable {
    case sanFrancisco = "San Francisco"
    case oakland = "Oakland"

    var id: String { rawValue }
}
