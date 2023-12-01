import Foundation
import PrefabAppUtilities

/// A struct that contains a specification for an item card.
public struct ItemCardSpec: Codable {
    /// Icon buttons.
    public let iconButtons: [ItemCardIconButton]?
    /// Menu items.
    public let menuItems: [ItemCardMenuItem]?

    /// Creates a new instance of `ItemCardSpec`.
    /// - Parameters:
    ///   - iconButtons: Icon buttons.
    ///   - menuItems: Menu items.
    public init(iconButtons: [ItemCardIconButton]?, menuItems: [ItemCardMenuItem]?) {
        self.iconButtons = iconButtons
        self.menuItems = menuItems
    }
}

/// An item card icon button.
public struct ItemCardIconButton: Codable {
    public let icon: String
    public let action: Action

    public init(icon: String, action: Action) {
        self.icon = icon
        self.action = action
    }
}

extension ItemCardIconButton {
    /// An item card icon button action.
    public enum Action: String, Codable, UnknownDecodable {
        case like
        case save
        case unknown
    }
}

/// An item card overflow menu item.
public struct ItemCardMenuItem: Codable {
    public let action: Action
    public let visibilityRule: VisibilityRule

    public init(action: Action, visibilityRule: VisibilityRule) {
        self.action = action
        self.visibilityRule = visibilityRule
    }
}

extension ItemCardMenuItem {
    /// An action the user can perform from an item card overflow menu.
    public enum Action: String, Codable, UnknownDecodable {
        case delete
        case unknown
    }
    /// A condition that controls the visibility of a menu item.
    public enum VisibilityRule: String, Codable, UnknownDecodable {
        /// The menu item is always shown.
        case always
        /// The menu item is shown on the current user's items only.
        case own
        case unknown
    }
}
