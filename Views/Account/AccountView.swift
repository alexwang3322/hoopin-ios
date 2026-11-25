import SwiftUI
import ClerkKit

/// Account screen — avatar, editable profile form (name, bio, location, gender, position — the
/// four fields the web's account page added beyond API_CONTRACT.md's `UserSummary`), Save/Sign
/// out, and small gray links out to the web app's legal/info pages (About/Terms/Privacy/Security/
/// Disclaimer live natively on the web now, not duplicated here — see AccountTabRootView.swift's
/// note). Reinterpreted as a native `Form` instead of the web's centered card layout. Reachable
/// only while signed in (AccountTabRootView gates just this tab).
struct AccountView: View {
    @Environment(ToastCenter.self) private var toast
    @Environment(Clerk.self) private var clerk
    @Environment(AppRouter.self) private var router

    @State private var formVM = AccountFormViewModel()
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var profileLoaded = false
    @State private var supportsEditing = false
    @State private var loadError: String?
    @State private var saveError = ""
    @State private var showingSaveError = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading profile…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let loadError {
                ContentUnavailableView {
                    Label("Couldn't load account", systemImage: "wifi.slash")
                } description: {
                    Text(loadError)
                } actions: {
                    Button("Try again") { Task { await loadProfile() } }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                accountForm
            }
        }
        .navigationTitle("Account")
        .task(id: clerk.user?.id) { await loadProfile() }
        .alert("Couldn't save profile", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveError)
        }
    }

    private var accountForm: some View {
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
            .disabled(!supportsEditing || isSaving)

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
            .disabled(!supportsEditing || isSaving)

            Section {
                if !supportsEditing {
                    Text("Profile editing is temporarily unavailable. Please try again later.")
                        .foregroundStyle(Theme.textSecondary)
                }
                Button("Save changes") {
                    Task { await saveProfile() }
                }
                .fontWeight(.semibold)
                .disabled(!supportsEditing || isSaving)
                if isSaving { ProgressView("Saving…") }

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
    }

    @MainActor
    private func loadProfile() async {
        guard let userId = clerk.user?.id else { return }
        isLoading = true
        profileLoaded = false
        supportsEditing = false
        loadError = nil
        do {
            let profile = try await LiveApiClient.getMe(userId: userId)
            guard !Task.isCancelled, clerk.user?.id == userId else { return }
            guard profile.id == userId else { throw AccountProfileError.incorrectAccount }
            try formVM.apply(profile)
            profileLoaded = true
            supportsEditing = profile.supportsEditing
        } catch {
            guard !Task.isCancelled, clerk.user?.id == userId else { return }
            loadError = message(for: error, action: "load")
        }
        isLoading = false
    }

    @MainActor
    private func saveProfile() async {
        guard profileLoaded, supportsEditing, !isSaving, let userId = clerk.user?.id else { return }
        let request = formVM.updateRequest
        guard !request.name.isEmpty else {
            showSaveError("Enter your name.")
            return
        }
        guard (request.bio?.count ?? 0) <= 500 else {
            showSaveError("Bio must be 500 characters or fewer.")
            return
        }
        isSaving = true
        defer { isSaving = false }
        do {
            let profile = try await LiveApiClient.updateMe(request, userId: userId)
            guard clerk.user?.id == userId else { return }
            guard profile.id == userId else { throw AccountProfileError.incorrectAccount }
            try formVM.apply(profile)
            toast.show("Profile updated.")
            // The server updates Clerk's name; refresh this session's user when possible.
            try? await clerk.user?.reload()
        } catch {
            guard clerk.user?.id == userId else { return }
            showSaveError(message(for: error, action: "save"))
        }
    }

    private func showSaveError(_ message: String) {
        saveError = message
        showingSaveError = true
    }

    private func message(for error: Error, action: String) -> String {
        if case let LiveApiClient.ApiError.server(_, _, message) = error { return message }
        if let profileError = error as? AccountProfileError {
            switch profileError {
            case .incorrectAccount: return "Your account changed. Please reopen this screen."
            case .unsupportedPreference: return "This profile contains an unsupported preference."
            }
        }
        return "Couldn't \(action) your profile. Please try again."
    }
}
