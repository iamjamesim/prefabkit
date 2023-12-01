import Foundation

/// A struct that contains contextual information about a page.
public struct PageContext: Hashable {
    /// A page ID.
    public let pageID: String?
    /// An object ID if the page belongs to an object (e.g. a user profile ID).
    public let objectID: String?

    public init(pageID: String?, objectID: String?) {
        self.pageID = pageID
        self.objectID = objectID
    }
}
