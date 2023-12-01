import Foundation

/// An enum that represents an app object type.
enum AppObjectType: String, Decodable, CaseIterable {
    /// A page's content.
    case pageContent
    /// An item collection.
    case itemCollection
    /// An item created by an app user.
    case item
    /// A user profile.
    case userProfile
}

extension AppObjectType {
    var dtoType: any AppObjectDTO.Type {
        if let dtoTypeOverride = Self.dtoTypeOverrides[self] {
            return dtoTypeOverride
        }

        switch self {
        case .pageContent:
            return PageContentDTO.self
        case .itemCollection:
            return ItemCollectionDTO.self
        case .item:
            return ItemDTO.self
        case .userProfile:
            return UserProfileDTO.self
        }
    }

    private static var dtoTypeOverrides = [AppObjectType: any AppObjectDTO.Type]()

    /// Overrides the associated DTO type.
    /// - Parameters:
    ///   - dtoType: An `AppObjectDTO.Type`.
    ///   - objectType: An `AppObjectType`.
    static func setDTOTypeOverride(_ dtoType: (any AppObjectDTO.Type)?, forObjectType objectType: AppObjectType) {
        dtoTypeOverrides[objectType] = dtoType
    }
}
