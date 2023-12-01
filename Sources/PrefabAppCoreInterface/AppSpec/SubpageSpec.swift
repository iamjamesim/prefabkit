import Foundation
import PrefabAppUtilities

/// A struct that represents a subpage specification.
public struct SubpageSpec: Identifiable, Codable {
    /// A subpage ID.
    public let id: String
    /// A title.
    public let title: String
    /// A page content query.
    public let contentQuery: PageContentQuery
    /// A message shown when the page is empty.
    public let emptyStateMessage: String
    /// A floating action button.
    public let floatingActionButton: FloatingActionButton?
    /// An item collection spec.
    public let itemCollectionSpec: ItemCollectionSpec?
    /// An item card spec.
    public let itemCardSpec: ItemCardSpec?
    /// An item form spec. If nil, the form is not shown.
    public let itemFormSpec: ItemFormSpec?
}
