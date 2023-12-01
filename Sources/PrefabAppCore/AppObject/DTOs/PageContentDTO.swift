import Foundation
import PrefabAppCoreInterface

struct PageContentDTO: AppObjectDTO {
    typealias Object = PageContent

    var id: String {
        [query.rawValue, pageId, objectId].compactMap { $0 }.joined(separator: "_")
    }
    let query: PageContentQuery
    let pageId: String?
    let objectId: String?
    let collectionIds: [String]
}
