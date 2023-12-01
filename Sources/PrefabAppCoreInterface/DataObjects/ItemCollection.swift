import Combine
import Foundation
import PrefabAppUtilities

public struct ItemCollection: Identifiable {
    public let id: String
    public let name: String?
    public let layout: Layout
    public var items: [ItemSubject]

    public init(id: String, name: String?, layout: Layout, items: [ItemSubject]) {
        self.id = id
        self.name = name
        self.layout = layout
        self.items = items
    }
}

extension ItemCollection {
    /// An enum that represents item collection layouts.
    public enum Layout: String, Codable, UnknownDecodable {
        /// A vertical list layout.
        case verticalList
        /// A horizontal list layout.
        case horizontalList
        /// An unknown layout type.
        case unknown
    }
}

public typealias ItemCollectionSubject = CurrentValueSubject<ItemCollection, Never>
