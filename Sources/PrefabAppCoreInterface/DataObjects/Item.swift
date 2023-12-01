import Combine
import Foundation
import PrefabAppUtilities

public struct Item: Identifiable {
    public let id: String
    public let itemType: ItemType
    public let name: String?
    public let description: String?
    public let body: String?
    public let imagePath: String?
    public let url: URL?
    public let creator: UserProfileSubject?
    public let isLiked: Bool
    public let isSaved: Bool
    public let insertedAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        itemType: ItemType,
        name: String?,
        description: String?,
        body: String?,
        imagePath: String?,
        url: URL?,
        creator: UserProfileSubject?,
        isLiked: Bool,
        isSaved: Bool,
        insertedAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.itemType = itemType
        self.name = name
        self.description = description
        self.body = body
        self.imagePath = imagePath
        self.url = url
        self.creator = creator
        self.isLiked = isLiked
        self.isSaved = isSaved
        self.insertedAt = insertedAt
        self.updatedAt = updatedAt
    }
}

public enum ItemType: String, Codable, UnknownDecodable {
    case socialPost
    case product
    case unknown
}

public typealias ItemSubject = CurrentValueSubject<Item, Never>
