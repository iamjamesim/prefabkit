import Combine
import Foundation

public struct PageContent: Identifiable {
    public var id: String {
        [query.rawValue, pageContext.pageID, pageContext.objectID].compactMap { $0 }.joined(separator: "_")
    }

    /// A page content query.
    public let query: PageContentQuery
    /// A page context object.
    public let pageContext: PageContext
    /// Item collections.
    public var collections: [ItemCollectionSubject]

    public init(query: PageContentQuery, pageContext: PageContext, collections: [ItemCollectionSubject]) {
        self.query = query
        self.pageContext = pageContext
        self.collections = collections
    }
}

public typealias PageContentSubject = CurrentValueSubject<PageContent, Never>
