@testable import PrefabAppCore

import Foundation
import PrefabAppCoreInterface

final class MockAppModel: AppModelProtocol {
    private(set) var upsertProfileCalled = false
    var upsertProfileRV: UserProfileSubject?
    @discardableResult
    func upsertProfile(inResponse response: APIResponse<UserProfileDTO>) throws -> UserProfileSubject {
        guard let upsertProfileRV else {
            throw MockError.nilReturnValue
        }
        upsertProfileCalled = true
        return upsertProfileRV
    }

    private(set) var upsertPageContentCalled = false
    var upsertPageContentRV: PageContentSubject?
    func upsertPageContent(inResponse response: APIResponse<PageContentDTO>) throws -> PageContentSubject {
        guard let upsertPageContentRV else {
            throw MockError.nilReturnValue
        }
        upsertPageContentCalled = true
        return upsertPageContentRV
    }

    private(set) var addItemCalled = false
    func addItem(inResponse response: APIResponse<ItemDTO>) throws {
        addItemCalled = true
    }

    private(set) var removeItemCalled = false
    func removeItem(itemID: String) throws {
        removeItemCalled = true
    }

    private(set) var addCollectionCalled = false
    func addCollection(inResponse response: APIResponse<ItemCollectionDTO>) throws {
        addCollectionCalled = true
    }

    private(set) var addCollectionItemCalled = false
    func addCollectionItem(inResponse response: APIResponse<ItemDTO>, collectionID: String) throws {
        addCollectionItemCalled = true
    }

    private(set) var removeCollectionCalled = false
    func removeCollection(collectionID: String) throws {
        removeCollectionCalled = true
    }

    private(set) var addLikedItemCalled = false
    func addLikedItem(inResponse response: APIResponse<ItemDTO>) throws {
        addLikedItemCalled = true
    }

    private(set) var removeLikedItemCalled = false
    func removeUnlikedItem(inResponse response: APIResponse<ItemDTO>) throws {
        removeLikedItemCalled = true
    }

    private(set) var addSavedItemCalled = false
    func addSavedItem(inResponse response: APIResponse<ItemDTO>) throws {
        addSavedItemCalled = true
    }

    private(set) var removeUnsavedItemCalled = false
    func removeUnsavedItem(inResponse response: APIResponse<ItemDTO>) throws {
        removeUnsavedItemCalled = true
    }
}
