import PrefabAppUI
import SwiftUI

/// A view that contains the login flow.
struct LoginFlow: View {
    private enum NavigationDestination: Hashable {
        case otpVerification(email: String)
    }

    @State private var navigationPath: [NavigationDestination] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            LoginEmailInputView(
                onEmailSend: { email in
                    navigationPath = [.otpVerification(email: email)]
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case let .otpVerification(email):
                    LoginOTPVerificationView(email: email)
                }
            }
        }
        .tint(AppColor.contentPrimary.color)
    }
}
