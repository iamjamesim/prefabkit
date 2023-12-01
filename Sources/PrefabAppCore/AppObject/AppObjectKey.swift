import Foundation

/// A struct that serves as a key for uniquely identifying an app object by its type and ID.
struct AppObjectKey: Hashable {
    /// An app object type.
    let objectType: AppObjectType
    /// An app object ID.
    let objectID: String
}
