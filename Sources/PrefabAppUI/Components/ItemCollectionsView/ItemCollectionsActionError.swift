import Foundation

/// An error that is thrown when the user attempts an unsupported action.
///
/// An unsupported action typically results when the app spec includes a new enum type that is decoded as `unknown`.
enum ItemCollectionsActionError: Error, LocalizedError {
    case unknownCardAction
    case unknownFormFieldType

    var errorDescription: String? {
        String(localized: "Unsupported Action", comment: "Error description.")
    }

    var failureReason: String? {
        switch self {
        case .unknownCardAction:
            return String(localized: "This action is not supported in this version of the app.", comment: "Error failure reason.")
        case .unknownFormFieldType:
            return String(localized: "A required form field has an unknown type. Please update to the latest version to access the form.", comment: "Error failure reason.")
        }
    }
}
