import Combine
import Foundation
import PrefabAppCoreInterface

/// The top-level interface to an app's Model layer.
protocol AppModelProtocol {
    /// Inserts or updates a user profile object to the store.
    /// - Parameter response: The API response containing the user profile to insert or update.
    /// - Returns: A `CurrentValueSubject` containing the inserted or updated user profile object.
    @discardableResult
    func upsertProfile(inResponse response: APIResponse<UserProfileDTO>) throws -> UserProfileSubject

    /// Inserts or updates a page content object to the store.
    /// - Parameter response: The API response containing the page content to insert or update.
    /// - Returns: A `CurrentValueSubject` containing the inserted or updated page content object.
    func upsertPageContent(inResponse response: APIResponse<PageContentDTO>) throws -> PageContentSubject

    /// Adds an item to the store.
    /// - Parameter response: The API response containing the item to add.
    func addItem(inResponse response: APIResponse<ItemDTO>) throws

    /// Removes an item from the store.
    /// - Parameter itemID: An item ID.
    func removeItem(itemID: String) throws

    /// Adds a collection to the store.
    /// - Parameter response: The API response containing the collection to add.
    func addCollection(inResponse response: APIResponse<ItemCollectionDTO>) throws

    /// Removes a collection from the store.
    /// - Parameters:
    ///   - collectionID: A collection ID.
    func removeCollection(collectionID: String) throws

    /// Adds a collection item to the store.
    /// - Parameters:
    ///   - response: The API response containing the collection item to add.
    ///   - collectionID: A collection ID.
    func addCollectionItem(inResponse response: APIResponse<ItemDTO>, collectionID: String) throws

    /// Adds a liked item to the store.
    /// - Parameter response: The API response containing the item to add.
    func addLikedItem(inResponse response: APIResponse<ItemDTO>) throws

    /// Removes an unliked item from the store.
    /// - Parameter response: The API response containing the item to remove.
    func removeUnlikedItem(inResponse response: APIResponse<ItemDTO>) throws

    /// Adds a saved item to the store.
    /// - Parameter response: The API response containing the item to add.
    func addSavedItem(inResponse response: APIResponse<ItemDTO>) throws

    /// Removes an unsaved item from the store.
    /// - Parameter response: The API response containing the item to remove.
    func removeUnsavedItem(inResponse response: APIResponse<ItemDTO>) throws
}
