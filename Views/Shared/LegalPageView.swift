import SwiftUI

/// Shared layout for the footer/Account "legal & info" screens (Terms, Privacy, Security, DMCA,
/// About — mirrors frontend/src/components/LegalPage/LegalPage.tsx). DisclaimerView predates this
/// and isn't migrated onto it, to avoid touching already-shipped content.
struct LegalPageView: View {
    struct Section: Identifiable {
        let id = UUID()
        let title: String?
        let body: String
        let bullets: [String]

        init(title: String? = nil, body: String = "", bullets: [String] = []) {
            self.title = title
            self.body = body
            self.bullets = bullets
        }
    }

    let title: String
    let intro: String
    let sections: [Section]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(intro)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 6) {
                        if let title = section.title {
                            Text(title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.ink)
                        }
                        if !section.body.isEmpty {
                            Text(section.body)
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.textSecondary)
                                .lineSpacing(3)
                        }
                        ForEach(section.bullets, id: \.self) { bullet in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                Text(bullet)
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
