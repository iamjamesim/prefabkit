import Combine
import Foundation
import PrefabAppCoreInterface

extension PageContent: AppObject {
    static let objectType: AppObjectType = .pageContent

    init(dto: PageContentDTO, relatedObjectProvider: AppObjectProvider) throws {
        self.init(
            query: dto.query,
            pageContext: PageContext(
                pageID: dto.pageId,
                objectID: dto.objectId
            ),
            collections: try dto.collectionIds.map { collectionID in
                try relatedObjectProvider.appObject(forID: collectionID)
            }
        )
    }
}
