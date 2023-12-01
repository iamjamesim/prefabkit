import Foundation
import PrefabAppUtilities

/// A struct that contains a specification for an item form.
public struct ItemFormSpec: Codable {
    /// An item type.
    public let itemType: ItemType
    /// A form title.
    public let title: String
    /// Fields to include in the form.
    public let fields: [FormFieldSpec]
}

/// A struct that contains a form field specification.
public struct FormFieldSpec: Codable {
    /// A content type.
    public let contentType: ContentType
    /// A name.
    public let name: String
    /// A placeholder.
    public let placeholder: String?
    /// A Boolean value that indicates whether the field is required.
    public let required: Bool
}

extension FormFieldSpec {
    /// An enum that represents field content types.
    public enum ContentType: String, Codable, UnknownDecodable {
        case text
        case image
        case url
        case unknown
    }
}
