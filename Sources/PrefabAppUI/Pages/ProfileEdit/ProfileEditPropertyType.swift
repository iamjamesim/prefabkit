import Foundation

/// An enum that represents profile property types.
enum ProfileEditPropertyType: Hashable {
    case username
    case displayName

    /// A form input type.
    var formInputType: FormInputType {
        switch self {
        case .username:
            return .username
        case .displayName:
            return .name
        }
    }
}
