import Foundation

/// A protocol conformed by all app object DTOs.
protocol AppObjectDTO: Decodable {
    /// The app object type for the DTO.
    associatedtype Object: AppObject

    /// An app object ID.
    var id: String { get }
}

extension AppObjectDTO {
    static var objectType: AppObjectType {
        Object.objectType
    }
}
