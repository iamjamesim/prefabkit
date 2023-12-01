import PrefabAppCoreInterface
import PrefabAppUI
import SwiftUI

/// A view that verifies the login code sent to the user's email.
struct LoginOTPVerificationView: View {
    @EnvironmentObject private var authClient: EnvironmentValueContainer<AuthClientProtocol>

    let email: String

    @State private var code: String = ""

    var body: some View {
        SingleInputForm(
            inputType: .otpCode,
            input: $code,
            submitButtonTitle: String(localized: "Continue", comment: "Button title"),
            submit: {
                try await authClient.value.verifySignInWithEmail(email: email, code: code)
            },
            onSuccess: {
                // The user should be logged in automatically by the change in auth state.
            }
        )
        .navigationTitle("Verify code")
    }
}
