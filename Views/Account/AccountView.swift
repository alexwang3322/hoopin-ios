import SwiftUI
import ClerkKit

/// Account screen — avatar, editable profile form (name, bio, location, gender, position — the
/// four fields the web's account page added beyond API_CONTRACT.md's `UserSummary`), Save/Sign
/// out, and links to the legal/info pages. Reinterpreted as a native `Form` instead of the web's
/// centered card layout. Reachable only while signed in (AuthGateView gates the whole app), so
/// `formVM.name` seeds from the real Clerk user, not the mock "Jamie Tran" story RunStore's
/// hosting/join-request logic still runs on independently — see AuthGateView's note.
struct AccountView: View {
    @Environment(RunStore.self) private var store
    @Environment(ToastCenter.self) private var toast
    @Environment(Clerk.self) private var clerk
    @Environment(\.navigate) private var navigate

    @State private var formVM = AccountFormViewModel(profile: MockData.currentAccount)

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    AvatarView(initials: formVM.displayInitials,
                               colorHex: store.currentUser.avatarColorHex, size: 72, fontSize: 26)
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
                        try? await clerk.auth.signOut()
                    }
                }
            }

            Section {
                Button("About") { navigate(.about) }
                Button("Terms") { navigate(.terms) }
                Button("Privacy") { navigate(.privacy) }
                Button("Security") { navigate(.security) }
                Button("Copyright / DMCA") { navigate(.dmca) }
                Button("Terms & Disclaimer") { navigate(.disclaimer) }
            }
        }
        .navigationTitle("Account")
        .onAppear(perform: seedNameFromClerk)
    }

    private func seedNameFromClerk() {
        guard let user = clerk.user else { return }
        let name = [user.firstName, user.lastName].compactMap { $0 }.joined(separator: " ")
        formVM.name = name.isEmpty ? "Hooper" : name
        // MockData.currentAccount's bio is Jamie Tran's mock story text — clear it rather than
        // show it under a real person's real name. Clerk has no bio field to seed a real one from.
        formVM.bio = ""
    }
}
