import SwiftUI

/// Account screen — avatar, editable profile form (name, bio, location, gender, position — the
/// four fields the web's account page added beyond API_CONTRACT.md's `UserSummary`), Save/Sign
/// out, and a link to the Disclaimer. Reinterpreted as a native `Form` instead of the web's
/// centered card layout.
struct AccountView: View {
    @Environment(RunStore.self) private var store
    @Environment(ToastCenter.self) private var toast
    @Environment(\.navigate) private var navigate

    @State private var formVM = AccountFormViewModel(profile: MockData.currentAccount)

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    AvatarView(initials: store.currentUser.initials,
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
                    ForEach(AccountLocation.allCases) { location in
                        Text(location.rawValue).tag(location)
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
                    toast.show("Signed out.")
                }
            }

            Section {
                Button("Terms & Disclaimer") {
                    navigate(.disclaimer)
                }
            }
        }
        .navigationTitle("Account")
    }
}
