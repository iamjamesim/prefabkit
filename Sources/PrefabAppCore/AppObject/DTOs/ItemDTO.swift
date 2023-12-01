import Foundation
import PrefabAppCoreInterface

struct ItemDTO: AppObjectDTO {
    typealias Object = Item

    let id: String
    let itemType: ItemType
    let name: String?
    let description: String?
    let body: String?
    let imagePath: String?
    let url: URL?
    let creatorId: String?
    let isLiked: Bool
    let isSaved: Bool
    let insertedAt: Date
    let updatedAt: Date
}
