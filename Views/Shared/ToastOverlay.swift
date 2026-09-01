import SwiftUI

/// Bottom-center pill, matching the web's `.toast` styling and 2.6s auto-dismiss (`ToastCenter`).
struct ToastOverlay: View {
    @Environment(ToastCenter.self) private var toast

    var body: some View {
        if let message = toast.message {
            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.background)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Capsule().fill(Theme.ink))
                .shadow(radius: 8, y: 4)
                .padding(.bottom, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeOut(duration: 0.2), value: toast.message)
        }
    }
}
