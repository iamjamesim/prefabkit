import Combine
import Foundation
import PrefabAppCoreInterface

extension Item: AppObject {
    static let objectType: AppObjectType = .item

    init(dto: ItemDTO, relatedObjectProvider: AppObjectProvider) throws {
        self.init(
            id: dto.id,
            itemType: dto.itemType,
            name: dto.name,
            description: dto.description,
            body: dto.body,
            imagePath: dto.imagePath,
            url: dto.url,
            creator: try dto.creatorId.map { creatorID in
                try relatedObjectProvider.appObject(forID: creatorID)
            },
            isLiked: dto.isLiked,
            isSaved: dto.isSaved,
            insertedAt: dto.insertedAt,
            updatedAt: dto.updatedAt
        )
    }
}
