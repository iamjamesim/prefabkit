import Foundation
import PrefabAppUtilities

/// An enum that represents a page type.
public enum PageType: String, Codable, UnknownDecodable {
    /// A content page.
    case content
    /// A user profile page.
    case userProfile
    /// An unknown page type.
    case unknown
}
