import SwiftUI
import ClerkKit

/// Account screen — avatar, editable profile form (name, bio, location, gender, position — the
/// four fields the web's account page added beyond API_CONTRACT.md's `UserSummary`), Save/Sign
/// out, and small gray links out to the web app's legal/info pages (About/Terms/Privacy/Security/
/// Disclaimer live natively on the web now, not duplicated here — see AccountTabRootView.swift's
/// note). Reinterpreted as a native `Form` instead of the web's centered card layout. Reachable
/// only while signed in (AccountTabRootView gates just this tab). Profile editing is still local
/// mock state until the backend supports it.
struct AccountView: View {
    @Environment(RunStore.self) private var store
    @Environment(ToastCenter.self) private var toast
    @Environment(Clerk.self) private var clerk
    @Environment(AppRouter.self) private var router

    @State private var formVM = AccountFormViewModel(profile: AccountProfile(
        user: UserSummary(id: "", name: "", initials: "", bio: nil, avatarColorHex: ""),
        location: .sd, gender: .preferNotToSay, position: .flexible
    ))
    @State private var seededUserId: String?

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    AvatarView(initials: formVM.displayInitials,
                               colorHex: ColorHash.avatarColorHex(for: clerk.user?.id ?? ""),
                               size: 72, fontSize: 26)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section("Profile") {
                TextField("Name", text: $formVM.name)
                TextField("Bio", text: $formVM.bio, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section {
                Picker("Location", selection: $formVM.location) {
                    ForEach(City.allCases) { city in
                        Text(city.label).tag(city)
                    }
                }
                Picker("Gender", selection: $formVM.gender) {
                    ForEach(Gender.allCases) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                Picker("Position", selection: $formVM.position) {
                    ForEach(PlayerPosition.allCases) { position in
                        Text(position.rawValue).tag(position)
                    }
                }
            } header: {
                Text("Location & game")
            } footer: {
                Text("Position helps hosts balance teams.")
            }

            Section {
                Button("Save changes") {
                    formVM.save(in: store)
                    toast.show("Profile updated.")
                }
                .fontWeight(.semibold)

                Button("Sign out", role: .destructive) {
                    Task {
                        router.selectedTab = .discover
                        do {
                            try await clerk.auth.signOut()
                            toast.show("Signed out.")
                        } catch {
                            router.selectedTab = .account
                            toast.show("Couldn't sign out. Please try again.")
                        }
                    }
                }
            } footer: {
                // Small gray text links out to the web app's own pages, matching how most apps
                // present legal/info links in Settings — not duplicated as native content here.
                VStack(spacing: 6) {
                    HStack(spacing: 14) {
                        Link("About", destination: URL(string: "https://hoopin.org/about")!)
                        Link("Terms", destination: URL(string: "https://hoopin.org/terms")!)
                        Link("Privacy", destination: URL(string: "https://hoopin.org/privacy")!)
                    }
                    HStack(spacing: 14) {
                        Link("Security", destination: URL(string: "https://hoopin.org/security")!)
                        Link("Terms & Disclaimer", destination: URL(string: "https://hoopin.org/disclaimer")!)
                    }
                }
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            }
        }
        .navigationTitle("Account")
        .onAppear(perform: seedNameFromClerk)
    }

    private func seedNameFromClerk() {
        guard let user = clerk.user, seededUserId != user.id else { return }
        let name = [user.firstName, user.lastName].compactMap { $0 }.joined(separator: " ")
        formVM.name = name.isEmpty ? "Hooper" : name
        // Clerk has no bio field; profile editing remains local until the backend supports it.
        formVM.bio = ""
        seededUserId = user.id
    }
}
