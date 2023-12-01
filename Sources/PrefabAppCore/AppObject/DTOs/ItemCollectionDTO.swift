import Foundation
import PrefabAppCoreInterface

struct ItemCollectionDTO: AppObjectDTO {
    typealias Object = ItemCollection

    let id: String
    let name: String?
    let layout: ItemCollection.Layout
    let itemIds: [String]
}
