import Foundation
import PrefabAppUtilities

/// An enum that represents a page content query type.
public enum PageContentQuery: String, Codable, UnknownDecodable {
    /// All items.
    case allItems
    /// Item collections.
    case collections
    /// Items created by the owner of the page.
    case creatorItems
    /// Items saved by the owner of the page.
    case saves
    /// Items liked by the owner of the page.
    case likes
    /// An unknown query.
    case unknown
}
