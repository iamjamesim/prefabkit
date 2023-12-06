import XCTest
@testable import PrefabAppCore

import Combine
import PrefabAppCoreInterface

final class AppModelTests: XCTestCase {
    func testUpsertProfile() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        let profileDTO = UserProfileDTO(
            id: "1",
            username: "johndoe",
            displayName: "John Doe",
            avatarUrl: nil,
            bio: nil,
            insertedAt: Date()
        )
        let userProfileSubject = try model.upsertProfile(
            inResponse: APIResponse(data: profileDTO, included: nil)
        )
        XCTAssertEqual(userProfileSubject.id, profileDTO.id)
    }

    func testUpsertPageContent() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        let pageContentDTO = PageContentDTO(
            query: .allItems,
            pageId: "1",
            objectId: nil,
            collectionIds: []
        )
        let pageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(data: pageContentDTO, included: nil)
        )
        XCTAssertEqual(pageContentSubject.id, pageContentDTO.id)
    }

    func testAddItem() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        // Add content feed page.
        let contentFeedPageContentDTO = PageContentDTO(
            query: .allItems,
            pageId: "1",
            objectId: nil,
            collectionIds: ["1"]
        )
        let contentFeedPageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: contentFeedPageContentDTO,
                included: [AnyAppObjectDTO(dto: ItemCollectionDTO(id: "1", name: nil, layout: .verticalList, itemIds: []))]
            )
        )
        // Add profile page.
        let profilePageContentDTO = PageContentDTO(
            query: .creatorItems,
            pageId: "2",
            objectId: "1",
            collectionIds: ["2"]
        )
        let profilePageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: profilePageContentDTO,
                included: [AnyAppObjectDTO(dto: ItemCollectionDTO(id: "2", name: nil, layout: .verticalList, itemIds: []))]
            )
        )
        // Add collections page.
        let collectionsPageContentDTO = PageContentDTO(
            query: .collections,
            pageId: "3",
            objectId: nil,
            collectionIds: ["3"]
        )
        let collectionsPageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: collectionsPageContentDTO,
                included: [AnyAppObjectDTO(dto: ItemCollectionDTO(id: "3", name: nil, layout: .horizontalList, itemIds: []))]
            )
        )

        // Add item.
        try model.addItem(
            inResponse: APIResponse(
                data: TestData.itemDTO,
                included: [AnyAppObjectDTO(dto: TestData.profileDTO)]
            ))
        try store.performWithinTransaction { proxy in
            let itemSubject: CurrentValueSubject<Item, Never>? = proxy.value(forID: TestData.itemDTO.id)
            XCTAssertNotNil(itemSubject)
        }

        XCTAssertEqual(contentFeedPageContentSubject.value.collections.first?.value.items.first?.id, TestData.itemDTO.id)
        XCTAssertEqual(profilePageContentSubject.value.collections.first?.value.items.first?.id, TestData.itemDTO.id)
        XCTAssertEqual(collectionsPageContentSubject.value.collections.first?.value.items.isEmpty, true)
    }

    func testAddItem_pageDefaultCollectionNotFound() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        // Add content feed page.
        let contentFeedPageContentDTO = PageContentDTO(
            query: .allItems,
            pageId: "1",
            objectId: nil,
            collectionIds: []
        )
        try model.upsertPageContent(
            inResponse: APIResponse(
                data: contentFeedPageContentDTO,
                included: []
            )
        )

        XCTAssertThrowsError(try {
            // Add item.
            try model.addItem(
                inResponse: APIResponse(
                    data: TestData.itemDTO,
                    included: [AnyAppObjectDTO(dto: TestData.profileDTO)]
                ))
        }()) { error in
            XCTAssertEqual(error as? AppModelError, AppModelError.pageDefaultCollectionNotFound)
        }
    }

    func testRemoveItem() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        // Add page with item.
        let pageContentDTO = PageContentDTO(
            query: .collections,
            pageId: "1",
            objectId: nil,
            collectionIds: ["1"]
        )
        let itemCollectionDTO = ItemCollectionDTO(id: "1", name: nil, layout: .verticalList, itemIds: ["1"])
        let pageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: pageContentDTO,
                included: [
                    AnyAppObjectDTO(dto: itemCollectionDTO),
                    AnyAppObjectDTO(dto: TestData.itemDTO),
                    AnyAppObjectDTO(dto: TestData.profileDTO)
                ]
            )
        )
        XCTAssertEqual(pageContentSubject.value.collections.first?.value.items.isEmpty, false)

        // Remove item.
        try model.removeItem(itemID: "1")
        XCTAssertEqual(pageContentSubject.value.collections.first?.value.items.isEmpty, true)
    }

    func testAddCollection() throws {let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        // Add collections page.
        let pageContentDTO = PageContentDTO(
            query: .collections,
            pageId: "1",
            objectId: nil,
            collectionIds: []
        )
        let pageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(data: pageContentDTO, included: nil)
        )

        // Add collection.
        let collectionDTO = ItemCollectionDTO(id: "1", name: "Test Collection", layout: .verticalList, itemIds: [])
        try model.addCollection(
            inResponse: APIResponse(data: collectionDTO, included: nil)
        )

        XCTAssertEqual(pageContentSubject.value.collections.first?.id, collectionDTO.id)
    }

    func testRemoveCollection() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        // Add page with collection.
        let pageContentDTO = PageContentDTO(
            query: .collections,
            pageId: "1",
            objectId: nil,
            collectionIds: ["1"]
        )
        let itemCollectionDTO = ItemCollectionDTO(id: "1", name: nil, layout: .verticalList, itemIds: ["1"])
        let pageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: pageContentDTO,
                included: [
                    AnyAppObjectDTO(dto: itemCollectionDTO),
                    AnyAppObjectDTO(dto: TestData.itemDTO),
                    AnyAppObjectDTO(dto: TestData.profileDTO)
                ]
            )
        )
        XCTAssertEqual(pageContentSubject.value.collections.isEmpty, false)

        // Remove collection.
        try model.removeCollection(collectionID: "1")
        XCTAssertEqual(pageContentSubject.value.collections.isEmpty, true)
    }

    func testAddCollectionItem() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        // Add profile page.
        let profilePageContentDTO = PageContentDTO(
            query: .creatorItems,
            pageId: "1",
            objectId: "1",
            collectionIds: ["1"]
        )
        let profilePageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: profilePageContentDTO,
                included: [AnyAppObjectDTO(dto: ItemCollectionDTO(id: "1", name: nil, layout: .verticalList, itemIds: []))]
            )
        )
        // Add collections page.
        let pageContentDTO = PageContentDTO(
            query: .collections,
            pageId: "2",
            objectId: nil,
            collectionIds: []
        )
        let pageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(data: pageContentDTO, included: nil)
        )

        // Add collection.
        let collectionDTO = ItemCollectionDTO(id: "1", name: "Test Collection", layout: .verticalList, itemIds: [])
        try model.addCollection(
            inResponse: APIResponse(data: collectionDTO, included: nil)
        )

        // Add item.
        try model.addCollectionItem(
            inResponse: APIResponse(
                data: TestData.itemDTO,
                included: [AnyAppObjectDTO(dto: TestData.profileDTO)]
            ),
            collectionID: "1"
        )

        XCTAssertEqual(profilePageContentSubject.value.collections.first?.value.items.first?.id, TestData.itemDTO.id)
        XCTAssertEqual(pageContentSubject.value.collections.first?.value.items.first?.id, TestData.itemDTO.id)
    }

    func testAddLikedItem() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        // Add likes pages.
        let likesPageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: PageContentDTO(
                    query: .likes,
                    pageId: "1",
                    objectId: nil,
                    collectionIds: ["1"]
                ),
                included: [AnyAppObjectDTO(dto: ItemCollectionDTO(id: "1", name: nil, layout: .verticalList, itemIds: []))]
            )
        )
        let profileLikesPageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: PageContentDTO(
                    query: .likes,
                    pageId: nil,
                    objectId: TestData.likedItemDTO.creatorId,
                    collectionIds: ["2"]
                ),
                included: [AnyAppObjectDTO(dto: ItemCollectionDTO(id: "2", name: nil, layout: .verticalList, itemIds: []))]
            )
        )

        // Like item.
        try model.addLikedItem(inResponse: APIResponse(
            data: TestData.likedItemDTO,
            included: [AnyAppObjectDTO(dto: TestData.profileDTO)]
        ))
        XCTAssertEqual(likesPageContentSubject.value.collections.first?.value.items.first?.id, TestData.likedItemDTO.id)
        XCTAssertEqual(profileLikesPageContentSubject.value.collections.first?.value.items.first?.id, TestData.likedItemDTO.id)
    }

    func testRemoveLikedItem() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        // Add likes pages.
        let likesPageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: PageContentDTO(
                    query: .likes,
                    pageId: "1",
                    objectId: nil,
                    collectionIds: ["1"]
                ),
                included: [
                    AnyAppObjectDTO(dto: ItemCollectionDTO(id: "1", name: nil, layout: .verticalList, itemIds: ["1"])),
                    AnyAppObjectDTO(dto: TestData.likedItemDTO),
                    AnyAppObjectDTO(dto: TestData.profileDTO)
                ]
            )
        )
        let profileLikesPageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: PageContentDTO(
                    query: .likes,
                    pageId: nil,
                    objectId: TestData.likedItemDTO.creatorId,
                    collectionIds: ["2"]
                ),
                included: [
                    AnyAppObjectDTO(dto: ItemCollectionDTO(id: "2", name: nil, layout: .verticalList, itemIds: ["1"])),
                    AnyAppObjectDTO(dto: TestData.likedItemDTO),
                    AnyAppObjectDTO(dto: TestData.profileDTO)
                ]
            )
        )

        // Unlike item.
        try model.removeUnlikedItem(inResponse: APIResponse(
            data: TestData.itemDTO,
            included: [AnyAppObjectDTO(dto: TestData.profileDTO)]
        ))
        XCTAssertEqual(likesPageContentSubject.value.collections.first?.value.items.isEmpty, true)
        XCTAssertEqual(profileLikesPageContentSubject.value.collections.first?.value.items.isEmpty, true)
    }

    func testAddSavedItem() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        // Add saves pages.
        let savesPageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: PageContentDTO(
                    query: .saves,
                    pageId: "1",
                    objectId: nil,
                    collectionIds: ["1"]
                ),
                included: [AnyAppObjectDTO(dto: ItemCollectionDTO(id: "1", name: nil, layout: .verticalList, itemIds: []))]
            )
        )
        let profileSavesPageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: PageContentDTO(
                    query: .saves,
                    pageId: nil,
                    objectId: TestData.savedItemDTO.creatorId,
                    collectionIds: ["2"]
                ),
                included: [AnyAppObjectDTO(dto: ItemCollectionDTO(id: "2", name: nil, layout: .verticalList, itemIds: []))]
            )
        )

        // Save item.
        try model.addSavedItem(inResponse: APIResponse(
            data: TestData.savedItemDTO,
            included: [AnyAppObjectDTO(dto: TestData.profileDTO)]
        ))
        XCTAssertEqual(savesPageContentSubject.value.collections.first?.value.items.first?.id, TestData.savedItemDTO.id)
        XCTAssertEqual(profileSavesPageContentSubject.value.collections.first?.value.items.first?.id, TestData.savedItemDTO.id)
    }

    func testRemoveSavedItem() throws {
        let store = AppObjectStore()
        let model = AppModel(objectStore: store)

        // Add saves pages.
        let savesPageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: PageContentDTO(
                    query: .saves,
                    pageId: "1",
                    objectId: nil,
                    collectionIds: ["1"]
                ),
                included: [
                    AnyAppObjectDTO(dto: ItemCollectionDTO(id: "1", name: nil, layout: .verticalList, itemIds: ["1"])),
                    AnyAppObjectDTO(dto: TestData.savedItemDTO),
                    AnyAppObjectDTO(dto: TestData.profileDTO)
                ]
            )
        )
        let profileSavesPageContentSubject = try model.upsertPageContent(
            inResponse: APIResponse(
                data: PageContentDTO(
                    query: .saves,
                    pageId: nil,
                    objectId: TestData.savedItemDTO.creatorId,
                    collectionIds: ["2"]
                ),
                included: [
                    AnyAppObjectDTO(dto: ItemCollectionDTO(id: "2", name: nil, layout: .verticalList, itemIds: ["1"])),
                    AnyAppObjectDTO(dto: TestData.savedItemDTO),
                    AnyAppObjectDTO(dto: TestData.profileDTO)
                ]
            )
        )

        // Unsave item.
        try model.removeUnsavedItem(inResponse: APIResponse(
            data: TestData.itemDTO,
            included: [AnyAppObjectDTO(dto: TestData.profileDTO)]
        ))
        XCTAssertEqual(savesPageContentSubject.value.collections.first?.value.items.isEmpty, true)
        XCTAssertEqual(profileSavesPageContentSubject.value.collections.first?.value.items.isEmpty, true)
    }
}
