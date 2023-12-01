import Foundation

/// A struct that represents an app page specification.
public struct PageSpec: Identifiable, Codable {
    /// A page ID.
    public let id: String
    /// A page type.
    public let pageType: PageType
    /// An object ID if the page belongs to an object (e.g. a user profile ID).
    public let objectID: String?
    /// A page title.
    public let title: String
    /// A page icon.
    public let icon: String
    /// Subpages to show in the content section of the page.
    public let subpages: [SubpageSpec]
}
