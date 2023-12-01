import SwiftUI

/// A view modifier that configures a form to present an alert on submission failure.
struct FormSubmissionFailureAlertModifier<Data>: ViewModifier {
    /// A binding to the form submission state.
    @Binding var submissionState: FormSubmissionState<Data>

    func body(content: Content) -> some View {
        content
            .alert(
                isPresented: .constant(submissionState.error != nil),
                error: submissionState.error,
                actions: {
                    Button {
                        submissionState = .idle
                    } label: {
                        Text("OK", comment: "Button title")
                    }
                }
            )
    }
}
