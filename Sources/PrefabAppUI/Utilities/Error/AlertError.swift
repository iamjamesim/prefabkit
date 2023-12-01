import Foundation

/// An error that wraps another error to make it displayable to the user in a system alert.
public struct AlertError: Error, LocalizedError {
    /// A wrapped error.
    let wrappedError: Error
    /// A fallback error description.
    let fallbackErrorDescription: String

    private var wrappedLocalizedError: LocalizedError? {
        wrappedError as? LocalizedError
    }

    /// Creates a new `AlertError` instance.
    /// - Parameters:
    ///  - wrappedError: A wrapped error.
    ///  - fallbackErrorDescription: A fallback error description.
    public init(
        wrappedError: Error,
        fallbackErrorDescription: String = String(
            localized: "Could not process your request.",
            comment: "Generic error description"
        )
    ) {
        self.wrappedError = wrappedError
        self.fallbackErrorDescription = fallbackErrorDescription
    }

    public var errorDescription: String? {
        wrappedLocalizedError?.errorDescription ?? fallbackErrorDescription
    }

    public var failureReason: String? {
        wrappedLocalizedError?.failureReason
    }

    public var recoverySuggestion: String? {
        wrappedLocalizedError?.recoverySuggestion
    }

    public var helpAnchor: String? {
        wrappedLocalizedError?.helpAnchor
    }
}
