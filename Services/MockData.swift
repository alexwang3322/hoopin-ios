import Foundation

/// Fixture data ported directly from `html/index.html`'s `PROFILES`, `RUN_DETAIL`/`KEZAR_DEFAULT`,
/// the six Discover cards, and the pending-request / My Runs markup. Kept in one place so
/// `RunStore` can seed itself without hunting through view code for starting state.
enum MockData {

    static let currentUserId = "u_jamie"

    // MARK: Profiles

    static let profiles: [UserSummary] = [
        UserSummary(id: "u_jamie", name: "Jamie Tran", initials: "JT",
                    bio: "Runs the Wednesday lunch crew · plays out of Kezar most weeks",
                    avatarColorHex: "E8631A"),
        UserSummary(id: "u_marcus", name: "Marcus Bell", initials: "MB",
                    bio: "Hosts the Rosa Parks Sunday run", avatarColorHex: "C98A43"),
        UserSummary(id: "u_priya", name: "Priya Nair", initials: "PN",
                    bio: "Hosts Dolores Park 3v3", avatarColorHex: "3E8161"),
        UserSummary(id: "u_deshawn", name: "Deshawn Carter", initials: "DC",
                    bio: "West Oakland Tuesday night regular", avatarColorHex: "8C2F2F"),
        UserSummary(id: "u_aiko", name: "Aiko Sato", initials: "AS",
                    bio: "Point guard, plays Wednesdays", avatarColorHex: "2E4A73"),
        UserSummary(id: "u_noah", name: "Noah Delgado", initials: "ND",
                    bio: "Runs a laid-back Sunday morning session at Bernal · brings the spare ball",
                    avatarColorHex: "8C2F2F"),
        UserSummary(id: "u_kai", name: "Kai Fujimoto", initials: "KF",
                    bio: "Plays center, tall enough to prove it", avatarColorHex: "6B4C7A"),
        UserSummary(id: "u_tyler", name: "Tyler Nguyen", initials: "TN",
                    bio: "Plays at the Presidio wall most weekends", avatarColorHex: "6B4C7A"),
        UserSummary(id: "u_sam", name: "Sam Okafor", initials: "SO",
                    bio: "New to the city, ran pickup in Chicago", avatarColorHex: "2E4A73"),
    ]

    // MARK: Runs

    /// The prototype's fixture "today" is early September 2026; dates are built relative to a
    /// fixed anchor rather than the device clock so the demo data reliably falls in Discover's
    /// "from date" filter regardless of when the app is actually run.
    private static func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int, _ min: Int) -> Date {
        var c = DateComponents()
        c.year = y; c.month = m; c.day = d; c.hour = h; c.minute = min
        c.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return Calendar(identifier: .gregorian).date(from: c) ?? Date()
    }

    static let runs: [Run] = [
        Run(id: "ev_rosa_parks", title: "Rosa Parks Sunday Run",
            description: "Full-court Sunday morning run, coffee after for whoever's still got legs. Casual pace, all levels welcome.",
            startsAt: date(2026, 9, 6, 8, 0), endsAt: date(2026, 9, 6, 10, 0),
            timezoneID: "America/Los_Angeles", format: .fiveVFiveFullCourt,
            venueName: "Rosa Parks Fields, San Francisco",
            exactAddress: "600 John F Shelley Dr, San Francisco, CA 94134",
            city: .sf, hostId: "u_marcus", capacity: 10, goingCount: 8, isDraft: false,
            visibility: .publicVisibility, autoApprove: false, attendeeIds: [],
            distanceMiles: 1.2, gradientStartHex: "F0793A", gradientEndHex: "7A2E12",
            createdAt: date(2026, 8, 20, 9, 0)),

        Run(id: "ev_dolores_3v3", title: "Dolores Park 3v3",
            description: "Half-court 3v3 at the Dolores Park courts. Winners stay on, losers grab water for the next game.",
            startsAt: date(2026, 9, 7, 18, 0), endsAt: date(2026, 9, 7, 20, 0),
            timezoneID: "America/Los_Angeles", format: .threeVThreeHalfCourt,
            venueName: "Dolores Park Courts, San Francisco",
            exactAddress: "19th & Dolores St, San Francisco, CA 94114",
            city: .sf, hostId: "u_priya", capacity: 6, goingCount: 4, isDraft: false,
            visibility: .publicVisibility, autoApprove: false, attendeeIds: [],
            distanceMiles: 2.8, gradientStartHex: "D9A05C", gradientEndHex: "6B4423",
            createdAt: date(2026, 8, 22, 9, 0)),

        Run(id: "ev_kezar_lunch", title: "Kezar Pavilion Lunch Run",
            description: "Full-court, next-basket-wins, call your own fouls. Bring a light shirt and a dark shirt — we split teams by colour when everyone's in. Doors unlock 15 minutes early.",
            startsAt: date(2026, 9, 9, 12, 0), endsAt: date(2026, 9, 9, 13, 0),
            timezoneID: "America/Los_Angeles", format: .fiveVFiveFullCourt,
            venueName: "Kezar Pavilion, San Francisco",
            exactAddress: "755 Frederick St, San Francisco, CA 94117",
            city: .sf, hostId: "u_jamie", capacity: 10, goingCount: 6, isDraft: false,
            visibility: .publicVisibility, autoApprove: false,
            attendeeIds: ["u_marcus", "u_aiko", "u_priya", "u_noah", "u_kai"],
            distanceMiles: 3.5, gradientStartHex: "3E8161", gradientEndHex: "163A29",
            createdAt: date(2026, 8, 15, 9, 0)),

        Run(id: "ev_west_oakland", title: "West Oakland Tuesday Run",
            description: "Full-court Tuesday night run at DeFremery. Regulars fill this one fast — it's already at capacity.",
            startsAt: date(2026, 9, 15, 18, 30), endsAt: date(2026, 9, 15, 20, 30),
            timezoneID: "America/Los_Angeles", format: .fiveVFiveFullCourt,
            venueName: "DeFremery Park, West Oakland",
            exactAddress: "1651 Adeline St, Oakland, CA 94607",
            city: .oak, hostId: "u_deshawn", capacity: 10, goingCount: 10, isDraft: false,
            visibility: .publicVisibility, autoApprove: false, attendeeIds: [],
            distanceMiles: 9.6, gradientStartHex: "A4453D", gradientEndHex: "3D1414",
            createdAt: date(2026, 8, 18, 9, 0)),

        Run(id: "ev_presidio", title: "Presidio Wednesday Pickup",
            description: "Half-court wall-ball at the Presidio courts. Small group, high rep count — good for getting shots up.",
            startsAt: date(2026, 9, 16, 18, 0), endsAt: date(2026, 9, 16, 19, 30),
            timezoneID: "America/Los_Angeles", format: .threeVThreeHalfCourt,
            venueName: "Presidio Wall Courts, San Francisco",
            exactAddress: "Presidio Blvd & Anza St, San Francisco, CA 94129",
            city: .sf, hostId: "u_aiko", capacity: 6, goingCount: 3, isDraft: false,
            visibility: .publicVisibility, autoApprove: false, attendeeIds: [],
            distanceMiles: 5.1, gradientStartHex: "3B4F70", gradientEndHex: "101820",
            createdAt: date(2026, 8, 24, 9, 0)),

        Run(id: "ev_bernal", title: "Bernal Rec Center Run",
            description: "Full-court Sunday morning run at Bernal. New run, still finding its regulars — come early to grab a side.",
            startsAt: date(2026, 9, 20, 9, 0), endsAt: date(2026, 9, 20, 11, 0),
            timezoneID: "America/Los_Angeles", format: .fiveVFiveFullCourt,
            venueName: "Bernal Heights Rec Center, San Francisco",
            exactAddress: "500 Cortland Ave, San Francisco, CA 94110",
            city: .sf, hostId: "u_noah", capacity: 10, goingCount: 2, isDraft: false,
            visibility: .publicVisibility, autoApprove: false, attendeeIds: [],
            distanceMiles: 4.0, gradientStartHex: "6B4C7A", gradientEndHex: "241830",
            createdAt: date(2026, 8, 25, 9, 0)),

        // Same story as backend/'s seed data (backend/src/db/seedData.ts's ev_doyle_outdoor) —
        // gives the Discover default (San Diego) a real run to show instead of an empty list.
        Run(id: "ev_doyle_outdoor", title: "Doyle Rec Center Outdoor Run",
            description: "Full-court run on Doyle's outdoor court. First-come, next-basket-wins, bring water — no shade on this one.",
            startsAt: date(2026, 9, 14, 9, 0), endsAt: date(2026, 9, 14, 11, 0),
            timezoneID: "America/Los_Angeles", format: .fiveVFiveFullCourt,
            venueName: "Doyle Recreation Center (Outdoor), San Diego",
            exactAddress: "8175 Regents Rd, San Diego, CA 92122",
            city: .sd, hostId: "u_kai", capacity: 10, goingCount: 0, isDraft: false,
            visibility: .publicVisibility, autoApprove: false, attendeeIds: [],
            distanceMiles: 0.8, gradientStartHex: "C98A43", gradientEndHex: "5A3A1A",
            createdAt: date(2026, 8, 27, 9, 0)),

        // Draft, never published — matches the web's `loadDraftIntoForm()` fixture. Several
        // fields are intentionally blank, exactly as the draft form leaves them.
        Run(id: "ev_sunday_skills_draft", title: "Sunday Skills Clinic",
            description: "Ball-handling and shooting drills before the run — still figuring out logistics.",
            startsAt: date(2026, 10, 4, 10, 0), endsAt: date(2026, 10, 4, 10, 0),
            timezoneID: "America/Los_Angeles", format: .fiveVFiveFullCourt,
            venueName: "", exactAddress: "",
            city: .sf, hostId: "u_jamie", capacity: nil, goingCount: 0, isDraft: true,
            visibility: .publicVisibility, autoApprove: false, attendeeIds: [],
            distanceMiles: 0, gradientStartHex: "E0954B", gradientEndHex: "5C3A17",
            createdAt: date(2026, 8, 28, 9, 0)),
    ]

    // MARK: Join requests

    /// Serves two roles at once, same as in `RunStore`: Kezar's two entries are the host-side
    /// "Requests to play" queue; Jamie's three entries are the viewer-side "My Runs" list.
    static let joinRequests: [JoinRequest] = [
        JoinRequest(id: "req_tyler_kezar", runId: "ev_kezar_lunch", requesterId: "u_tyler",
                    message: "Looking for a lunch run closer to my office — used to run at the Presidio on weekends but the commute's rough midweek.",
                    status: .pending, createdAt: Date().addingTimeInterval(-4 * 3600), decidedAt: nil, declineReason: nil),
        JoinRequest(id: "req_sam_kezar", runId: "ev_kezar_lunch", requesterId: "u_sam",
                    message: "Just moved from Chicago, used to run at the park district gyms there. Can vouch I show up on time and pass the ball.",
                    status: .pending, createdAt: Date().addingTimeInterval(-24 * 3600), decidedAt: nil, declineReason: nil),

        JoinRequest(id: "req_jamie_dolores", runId: "ev_dolores_3v3", requesterId: "u_jamie",
                    message: nil, status: .pending, createdAt: Date().addingTimeInterval(-2 * 86400),
                    decidedAt: nil, declineReason: nil),
        JoinRequest(id: "req_jamie_rosa", runId: "ev_rosa_parks", requesterId: "u_jamie",
                    message: nil, status: .approved, createdAt: Date().addingTimeInterval(-10 * 86400),
                    decidedAt: Date().addingTimeInterval(-9 * 86400), declineReason: nil),
        JoinRequest(id: "req_jamie_west_oakland", runId: "ev_west_oakland", requesterId: "u_jamie",
                    message: nil, status: .declined, createdAt: Date().addingTimeInterval(-14 * 86400),
                    decidedAt: Date().addingTimeInterval(-13 * 86400),
                    declineReason: "Full this month — try the October run."),
        // Not present in the web's hardcoded My Runs markup even though `RUN_DETAIL.ev_presidio`
        // says the viewer is "approved" there — a prototype inconsistency. This app derives My
        // Runs from real join-request data, so it's included for internal consistency.
        JoinRequest(id: "req_jamie_presidio", runId: "ev_presidio", requesterId: "u_jamie",
                    message: nil, status: .approved, createdAt: Date().addingTimeInterval(-6 * 86400),
                    decidedAt: Date().addingTimeInterval(-5 * 86400), declineReason: nil),
    ]

    static let currentAccount = AccountProfile(
        user: profiles.first { $0.id == currentUserId }!,
        location: .sd,
        gender: .preferNotToSay,
        position: .flexible
    )
}
