import Combine
import Foundation
import PrefabAppCoreInterface

extension ItemCollection: AppObject {
    static let objectType: AppObjectType = .itemCollection

    init(dto: ItemCollectionDTO, relatedObjectProvider: AppObjectProvider) throws {
        self.init(
            id: dto.id,
            name: dto.name,
            layout: dto.layout,
            items: try dto.itemIds.map { itemID in
                try relatedObjectProvider.appObject(forID: itemID)
            }
        )
    }
}
