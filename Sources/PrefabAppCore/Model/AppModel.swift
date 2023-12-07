import Combine
import Foundation
import PrefabAppCoreInterface

final class AppModel: AppModelProtocol {
    /// A side effect to perform after merging API response objects.
    private struct MergeSideEffect<ResponseObject, TargetObject> {
        /// A closure to perform on the target objects.
        let body: (
            CurrentValueSubject<ResponseObject, Never>,
            [CurrentValueSubject<TargetObject, Never>]
        ) throws -> Void
    }

    private let objectStore: AppObjectStore
    private let currentUserID: String

    /// Creates a new `AppModel` instance.
    /// - Parameters:
    ///   objectStore: An object store to use for storing and retrieving app objects.
    ///   currentUserID: The ID of the current user whose session is active.
    init(objectStore: AppObjectStore, currentUserID: String) {
        self.objectStore = objectStore
        self.currentUserID = currentUserID
    }

    func insertProfile(userProfile: UserProfile) async throws -> UserProfileSubject {
        try await objectStore.performWithinTransactionAsync { proxy in
            proxy.mergeValue(id: userProfile.id, newValue: userProfile)
        }
    }

    @discardableResult
    func upsertProfile(inResponse response: APIResponse<UserProfileDTO>) throws -> UserProfileSubject {
        try mergeObjects(inResponse: response)
    }

    @discardableResult
    func upsertPageContent(inResponse response: APIResponse<PageContentDTO>) throws -> PageContentSubject {
        try mergeObjects(inResponse: response)
    }

    func addItem(inResponse response: APIResponse<ItemDTO>) throws {
        let appItemInsertEffect = MergeSideEffect<Item, PageContent>(body: { newItem, targetObjects in
            for pageContent in targetObjects {
                if pageContent.value.query == .allItems ||
                    Self.isCreatorItem(pageContent: pageContent.value, item: newItem.value) {
                    guard let firstCollection = pageContent.value.collections.first else {
                        throw AppModelError.pageDefaultCollectionNotFound
                    }
                    firstCollection.value.items.insert(newItem, at: 0)
                }
            }
        })
        try mergeObjects(
            inResponse: response,
            sideEffect: appItemInsertEffect
        )
    }

    func removeItem(itemID: String) throws {
        try objectStore.performWithinTransaction { objectStoreProxy in
            try objectStoreProxy.performObjectUpdates { (pageContents: [CurrentValueSubject<PageContent, Never>]) in
                // Remove item from all collections.
                for collection in pageContents.flatMap({ $0.value.collections }) {
                    collection.value.items.removeAll(where: { $0.id == itemID })
                }
            }
        }
    }

    func addCollection(inResponse response: APIResponse<ItemCollectionDTO>) throws {
        let collectionInsertEffect = MergeSideEffect<ItemCollection, PageContent>(body: { newCollection, targetObjects in
            targetObjects.first { pageContent in
                pageContent.value.query == .collections
            }?.value.collections.append(newCollection)
        })
        try mergeObjects(
            inResponse: response,
            sideEffect: collectionInsertEffect
        )
    }

    func removeCollection(collectionID: String) throws {
        try objectStore.performWithinTransaction { objectStoreProxy in
            try objectStoreProxy.performObjectUpdates { (pageContents: [CurrentValueSubject<PageContent, Never>]) in
                // Remove collection from all pages.
                for pageContent in pageContents {
                    pageContent.value.collections.removeAll(where: { $0.id == collectionID })
                }
            }
        }
    }

    func addCollectionItem(inResponse response: APIResponse<ItemDTO>, collectionID: String) throws {
        let collectionItemInsertEffect = MergeSideEffect<Item, PageContent>(body: { newItem, targetObjects in
            for pageContent in targetObjects {
                if pageContent.value.query == .collections {
                    pageContent.value.collections.first { collection in
                        collection.id == collectionID
                    }?.value.items.append(newItem)
                } else if Self.isCreatorItem(pageContent: pageContent.value, item: newItem.value) {
                    guard let firstCollection = pageContent.value.collections.first else {
                        throw AppModelError.pageDefaultCollectionNotFound
                    }
                    firstCollection.value.items.insert(newItem, at: 0)
                }
            }
        })
        try mergeObjects(
            inResponse: response,
            sideEffect: collectionItemInsertEffect
        )
    }

    func addLikedItem(inResponse response: APIResponse<ItemDTO>) throws {
        let likedItemInsertEffect = MergeSideEffect<Item, PageContent>(body: { likedItem, targetObjects in
            targetObjects.first { pageContent in
                pageContent.value.query == .likes &&
                self.belongsToCurrentUser(pageContext: pageContent.value.pageContext)
            }?.value.collections.first?.value.items.insert(likedItem, at: 0)
        })
        try mergeObjects(
            inResponse: response,
            sideEffect: likedItemInsertEffect
        )
    }

    func removeUnlikedItem(inResponse response: APIResponse<ItemDTO>) throws {
        let unlikedItemRemoveEffect = MergeSideEffect<Item, PageContent>(body: { unlikedItem, targetObjects in
            targetObjects.first { pageContent in
                pageContent.value.query == .likes &&
                self.belongsToCurrentUser(pageContext: pageContent.value.pageContext)
            }?.value.collections.first?.value.items.removeAll(where: { $0.id == unlikedItem.id })
        })
        try mergeObjects(
            inResponse: response,
            sideEffect: unlikedItemRemoveEffect
        )
    }

    func addSavedItem(inResponse response: APIResponse<ItemDTO>) throws {
        let savedItemInsertEffect = MergeSideEffect<Item, PageContent>(body: { savedItem, targetObjects in
            targetObjects.first { pageContent in
                pageContent.value.query == .saves &&
                self.belongsToCurrentUser(pageContext: pageContent.value.pageContext)
            }?.value.collections.first?.value.items.insert(savedItem, at: 0)
        })
        try mergeObjects(
            inResponse: response,
            sideEffect: savedItemInsertEffect
        )
    }

    func removeUnsavedItem(inResponse response: APIResponse<ItemDTO>) throws {
        let unsavedItemRemoveEffect = MergeSideEffect<Item, PageContent>(body: { unsavedItem, targetObjects in
            targetObjects.first { pageContent in
                pageContent.value.query == .saves &&
                self.belongsToCurrentUser(pageContext: pageContent.value.pageContext)
            }?.value.collections.first?.value.items.removeAll(where: { $0.id == unsavedItem.id })
        })
        try mergeObjects(
            inResponse: response,
            sideEffect: unsavedItemRemoveEffect
        )
    }

    private func belongsToCurrentUser(pageContext: PageContext) -> Bool {
        pageContext.objectID == nil || pageContext.objectID == currentUserID
    }

    /// Merges objects in the API response to the store, and then returns app objects that correspond to the main data objects in the API response.
    @discardableResult
    private func mergeObjects<T: AppObject, U: AppObject>(
        inResponse response: APIResponse<T.DTO>,
        sideEffect: AppModel.MergeSideEffect<T, U>?
    ) throws -> CurrentValueSubject<T, Never> {
        try objectStore.performWithinTransaction { objectStoreProxy in
            // 1. Process data and included objects.
            let responseProcessor = APIResponseProcessor<T>(response: response, objectStoreProxy: objectStoreProxy)
            let responseObject = try responseProcessor.dataObject()

            // 2. Perform any side effect.
            if let sideEffect {
                try objectStoreProxy.performObjectUpdates { targetObjects in
                    try sideEffect.body(responseObject, targetObjects)
                }
            }

            return responseObject
        }
    }

    /// Merges objects in the API response to the store, and then returns app objects that correspond to the main data objects in the API response.
    @discardableResult
    private func mergeObjects<T: AppObject>(
        inResponse response: APIResponse<T.DTO>
    ) throws -> CurrentValueSubject<T, Never> {
        try mergeObjects(inResponse: response, sideEffect: nil as AppModel.MergeSideEffect<T, T>?)
    }

    private static func isCreatorItem(pageContent: PageContent, item: Item) -> Bool {
        pageContent.query == .creatorItems && item.creator?.id == pageContent.pageContext.objectID
    }
}

enum AppModelError: Error {
    case pageDefaultCollectionNotFound
}
