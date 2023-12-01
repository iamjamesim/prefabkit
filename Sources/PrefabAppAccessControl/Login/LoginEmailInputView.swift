import PrefabAppCoreInterface
import PrefabAppUI
import SwiftUI

/// A view that starts the login process with the user's email.
struct LoginEmailInputView: View {
    @EnvironmentObject private var authClient: EnvironmentValueContainer<AuthClientProtocol>

    @State private var email: String = ""

    /// A closure that is called when the login email is sent successfully.
    let onEmailSend: (String) -> Void

    var body: some View {
        SingleInputForm(
            inputType: .email,
            input: $email,
            submitButtonTitle: String(localized: "Continue", comment: "Button title"),
            submit: {
                // TODO: perform input validation before submitting
                try await authClient.value.signInWithEmail(email)
            },
            onSuccess: {
                onEmailSend(email)
            }
        )
        .navigationTitle("Log in or sign up")
    }
}
