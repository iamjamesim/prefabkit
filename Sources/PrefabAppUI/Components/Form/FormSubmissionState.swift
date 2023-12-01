import Foundation

/// An enum that represents form submission states.
public enum FormSubmissionState<Data> {
    /// The idle state.
    case idle
    /// The submitting state.
    case submitting
    /// The success state.
    case success(Data)
    /// The failure state.
    case failure(AlertError)

    /// A Boolean value that indicates whether the form is submitting.
    public var isSubmitting: Bool {
        if case .submitting = self {
            return true
        } else {
            return false
        }
    }

    /// An error, if in the failure state.
    var error: AlertError? {
        if case let .failure(error) = self {
            return error
        } else {
            return nil
        }
    }
}
