import Foundation
import PrefabAppUtilities

/// An enum that represents a destination type.
public enum DestinationType: String, Codable, UnknownDecodable {
    /// A user profile.
    case userProfile
    /// An unknown type.
    case unknown
}
