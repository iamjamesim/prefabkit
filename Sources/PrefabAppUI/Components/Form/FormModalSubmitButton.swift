import PrefabAppCoreInterface
import SwiftUI

/// A navigation bar button for form submissions.
///
/// On tap, the button shows a progress spinner, and triggers the submit action.
/// If the submission fails, a failure alert is displayed.
/// If the submission succeeds, the form is auto-dismissed.
public struct FormModalSubmitButton<Data>: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var analytics: EnvironmentValueContainer<AnalyticsProtocol>

    /// A submit button title.
    let title: String
    /// A binding to the form submission state.
    @Binding var submissionState: FormSubmissionState<Data>
    /// A closure that performs the form submission.
    let submit: () async throws -> Data

    public init(
        title: String,
        submissionState: Binding<FormSubmissionState<Data>>,
        submit: @escaping () async throws -> Data
    ) {
        self.title = title
        _submissionState = submissionState
        self.submit = submit
    }

    public var body: some View {
        Button {
            submissionState = .submitting
            Task {
                do {
                    submissionState = .success(try await submit())
                    dismiss()
                } catch {
                    analytics.value.logError(error)
                    submissionState = .failure(AlertError(wrappedError: error))
                }
            }
        } label: {
            ZStack {
                ProgressView()
                    .tint(AppColor.contentPrimary.color)
                    .opacity(submissionState.isSubmitting ? 1 : 0)
                Text(title)
                    .fontWeight(.semibold)
                    .opacity(submissionState.isSubmitting ? 0 : 1)
            }
        }
        .modifier(FormSubmissionFailureAlertModifier(submissionState: $submissionState))
    }
}
