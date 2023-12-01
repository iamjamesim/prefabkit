import Foundation
import SwiftUI

/// A service that coordinates data operations in an app.
///
/// The app service acts as the frontend interface for interacting with the core data and business logic of an app.
/// UI components primarily depend on this interface to perform API and Model operations.
public protocol AppServiceProtocol {
    /// Gets the app spec.
    /// - Returns: The app spec.
    func appSpec() async throws -> AppSpec

    /// Gets the contents of a page given a page content query and context.
    /// - Parameters:
    ///   - query: A page content query.
    ///   - pageContext: A page context object.
    /// - Returns: A `PageContentSubject` containing the page content.
    func pageContent(query: PageContentQuery, pageContext: PageContext) async throws -> PageContentSubject

    /// Downloads an image from a given path in storage.
    /// - Parameter path: An image path in storage.
    /// - Returns: The downloaded image.
    func downloadImage(atPath path: String) async throws -> Image

    /// Creates an item given a multipart request.
    /// - Parameters:
    ///   - request: A multipart request.
    ///   - itemType: An item type.
    ///   - collectionID: A collection ID, if the item is being added to a collection.
    func createItem(withRequest request: MultipartRequest, itemType: ItemType, collectionID: String?) async throws

    /// Deletes an item.
    /// - Parameter itemID: An item ID.
    func deleteItem(itemID: String) async throws

    /// Creates an item collection.
    /// - Parameters:
    ///   - name: A collection name.
    func createItemCollection(name: String) async throws

    /// Deletes an item collection.
    /// - Parameter collectionID: A collection ID.
    func deleteItemCollection(collectionID: String) async throws

    /// Likes an item for the current user.
    /// - Parameter itemID: An item ID.
    func likeItem(itemID: String) async throws

    /// Unlikes an item for the current user.
    /// - Parameter itemID: An item ID.
    func unlikeItem(itemID: String) async throws

    /// Saves an item for the current user.
    /// - Parameter itemID: An item ID.
    func saveItem(itemID: String) async throws

    /// Unsaves an item for the current user.
    /// - Parameter itemID: An item ID.
    func unsaveItem(itemID: String) async throws
}
