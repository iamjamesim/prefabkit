import SwiftUI

/// An enum that represents a form input type.
public enum FormInputType {
    case email
    case name
    case otpCode
    case username

    /// A text field label.
    var label: String {
        switch self {
        case .email:
            return String(localized: "Email", comment: "Form input label")
        case .name:
            return String(localized: "Name", comment: "Form input label")
        case .otpCode:
            return String(localized: "Code", comment: "Form input label")
        case .username:
            return String(localized: "Username", comment: "Form input label")
        }
    }

    /// A `UITextContentType`.
    var textContentType: UITextContentType? {
        switch self {
        case .email:
            return .emailAddress
        case .name:
            return nil
        case .otpCode:
            return .oneTimeCode
        case .username:
            return .username
        }
    }

    /// A `UIKeyboardType`.
    var keyboardType: UIKeyboardType {
        switch self {
        case .name,
             .otpCode,
             .username:
            return .default
        case .email:
            return .emailAddress
        }
    }

    /// A `TextInputAutocapitalization`.
    var textInputAutocapitalization: TextInputAutocapitalization {
        switch self {
        case .email,
             .otpCode,
             .username:
            return .never
        case .name:
            return .words
        }
    }

    /// A Boolean value that indicates whether autocorrection is disabled.
    var autocorrectionDisabled: Bool {
        switch self {
        case .email,
             .otpCode,
             .username:
            return true
        case .name:
            return false
        }
    }
}
