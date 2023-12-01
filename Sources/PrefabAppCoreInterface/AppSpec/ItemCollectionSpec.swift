import Foundation
import PrefabAppUtilities

/// A struct that contains a specification for each item collection.
public struct ItemCollectionSpec: Codable {
    /// Whether to show a new item button for each collection.
    public let newItemButtonEnabled: Bool
    /// Menu items.
    public let menuItems: [ItemCollectionMenuItem]?
}

/// A collection menu item.
public struct ItemCollectionMenuItem: Codable {
    public let action: Action
}

extension ItemCollectionMenuItem {
    public enum Action: String, Codable, UnknownDecodable {
        case delete
        case unknown
    }
}
