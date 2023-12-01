import PrefabAppCoreInterface
import SwiftUI

/// A form that accepts a single input.
public struct SingleInputForm<Data>: View {
    @EnvironmentObject private var analytics: EnvironmentValueContainer<AnalyticsProtocol>

    /// An input type.
    let inputType: FormInputType
    /// A binding to the text input.
    @Binding var input: String
    /// A submit button title.
    let submitButtonTitle: String
    /// A closure that performs the form submission.
    let submit: () async throws -> Data
    /// A closure that is called when the form submission succeeds.
    let onSuccess: (Data) -> Void

    @State private var submissionState: FormSubmissionState<Data> = .idle

    /// Creates a new `SingleInputForm` instance.
    /// - Parameters:
    ///   - inputType: An input type.
    ///   - input: A binding to the text input.
    ///   - submitButtonTitle: A submit button title.
    ///   - submit: A closure that performs the form submission.
    ///   - onSuccess: A closure that is called when the form submission succeeds.
    public init(
        inputType: FormInputType,
        input: Binding<String>,
        submitButtonTitle: String,
        submit: @escaping () async throws -> Data,
        onSuccess: @escaping (Data) -> Void
    ) {
        self.inputType = inputType
        _input = input
        self.submitButtonTitle = submitButtonTitle
        self.submit = submit
        self.onSuccess = onSuccess
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                FormInputField(input: $input, inputType: inputType)
                Button {
                    submissionState = .submitting
                    Task {
                        do {
                            let data = try await submit()
                            submissionState = .success((data))
                            onSuccess(data)
                        } catch {
                            analytics.value.logError(error)
                            submissionState = .failure(AlertError(wrappedError: error))
                        }
                    }
                } label: {
                    ZStack {
                        Group {
                            if submissionState.isSubmitting {
                                ProgressView()
                                    .tint(AppColor.buttonPrimaryForeground.color)
                                    .frame(height: submitButtonTextHeight)
                            } else {
                                Text(submitButtonTitle)
                                    .foregroundColor(AppColor.buttonPrimaryForeground.color)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(AppColor.buttonPrimaryBackground.color)
                        )
                    }
                }
            }
            .disabled(submissionState.isSubmitting)
            .padding(24)
            .modifier(FormSubmissionFailureAlertModifier(submissionState: $submissionState))
        }
    }

    private var submitButtonTextHeight: CGFloat {
        let constrainedSize = CGSize(width: 100, height: CGFloat.greatestFiniteMagnitude)
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let boundingRect = NSString(string: "")
            .boundingRect(
                with: constrainedSize,
                options: options,
                attributes: attributes,
                context: nil
            )
        return ceil(boundingRect.height)
    }
}
