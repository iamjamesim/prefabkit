import SwiftUI

/// A view modifier that configures a navigation bar for a form modal.
public struct FormModalNavigationBarModifier<Data>: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    /// A navigation bar title.
    let title: String
    /// A submit button title.
    let submitButtonTitle: String
    /// A Boolean value that indicates whether the submit button is disabled.
    let isSubmitDisabled: Bool
    /// A binding to the form submission state.
    @Binding var submissionState: FormSubmissionState<Data>
    /// A closure that performs the form submission.
    let submit: () async throws -> Data

    public init(
        title: String,
        submitButtonTitle: String,
        isSubmitDisabled: Bool,
        submissionState: Binding<FormSubmissionState<Data>>,
        submit: @escaping () async throws -> Data
    ) {
        self.title = title
        self.submitButtonTitle = submitButtonTitle
        self.isSubmitDisabled = isSubmitDisabled
        _submissionState = submissionState
        self.submit = submit
    }

    public func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(AppColor.contentPrimary.color)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    FormModalSubmitButton(
                        title: submitButtonTitle,
                        submissionState: $submissionState,
                        submit: submit
                    )
                    .disabled(isSubmitDisabled)
                }
            }
    }
}
