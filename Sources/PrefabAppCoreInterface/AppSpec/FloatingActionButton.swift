import Foundation
import PrefabAppUtilities

/// A floating action button shown on a page.
public struct FloatingActionButton: Codable {
    public let icon: String
    public let action: Action
}

extension FloatingActionButton {
    public enum Action: String, Codable, UnknownDecodable {
        case addItem
        case addCollection
        case unknown
    }
}
