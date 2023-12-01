import Combine
import Foundation
import PrefabAppCoreInterface
import SwiftUI

final class AppService: AppServiceProtocol {
    private let appID: String
    private let apiClient: APIClientProtocol
    private let appModel: AppModelProtocol

    /// Creates a new `AppService` instance.
    /// - Parameters:
    ///   - appID: An app ID.
    ///   - apiClient: An API client to use to perform API operations.
    ///   - appModel: An app model to use to store and retrieve app objects.
    init(
        appID: String,
        apiClient: APIClientProtocol,
        appModel: AppModelProtocol
    ) {
        self.appID = appID
        self.apiClient = apiClient
        self.appModel = appModel
    }

    func appSpec() async throws -> AppSpec {
        struct AppSpecParams: Encodable {
            let appId: String
        }
        return try await apiClient.perform(operation: .appSpec, params: AppSpecParams(appId: appID))
    }

    func pageContent(query: PageContentQuery, pageContext: PageContext) async throws -> PageContentSubject {
        struct PageContentParams: Encodable {
            let appId: String
            let query: PageContentQuery
            let pageId: String?
            let objectId: String?
        }

        let response: APIResponse<PageContentDTO> = try await apiClient
            .perform(
                operation: APIOperation.pageContent,
                params: PageContentParams(
                    appId: appID,
                    query: query,
                    pageId: pageContext.pageID,
                    objectId: pageContext.objectID
                )
            )
        return try appModel.upsertPageContent(inResponse: response)
    }

    func downloadImage(atPath path: String) async throws -> Image {
        let data = try await apiClient.download(fromPath: path)
        guard let image = UIImage(data: data) else {
            throw APIOperationError.unexpectedResponse
        }
        return Image(uiImage: image)
    }

    func createItem(withRequest request: MultipartRequest, itemType: ItemType, collectionID: String?) async throws {
        // Add params to request.
        var request = request
        request.addField(.init(name: "itemType", value: itemType.rawValue))
        request.addField(.init(name: "appId", value: appID))
        if let collectionID {
            request.addField(.init(name: "collectionId", value: collectionID))
        }

        let response: APIResponse<ItemDTO> = try await apiClient
            .perform(operation: APIOperation.itemCreate, multipartRequest: request)
        if let collectionID {
            try appModel.addCollectionItem(inResponse: response, collectionID: collectionID)
        } else {
            try appModel.addItem(inResponse: response)
        }
    }

    func deleteItem(itemID: String) async throws {
        struct Params: Encodable {
            let itemId: String
        }
        try await apiClient.perform(operation: APIOperation.itemDelete, params: Params(itemId: itemID))
        try appModel.removeItem(itemID: itemID)
    }

    func createItemCollection(name: String) async throws {
        struct Params: Encodable {
            let appId: String
            let name: String
        }
        let response: APIResponse<ItemCollectionDTO> = try await apiClient
            .perform(
                operation: APIOperation.itemCollectionCreate,
                params: Params(appId: appID, name: name)
            )
        try appModel.addCollection(inResponse: response)
    }

    func deleteItemCollection(collectionID: String) async throws {
        struct Params: Encodable {
            let collectionId: String
        }
        try await apiClient
            .perform(operation: APIOperation.itemCollectionDelete, params: Params(collectionId: collectionID))
        try appModel.removeCollection(collectionID: collectionID)
    }

    func likeItem(itemID: String) async throws {
        struct Params: Encodable {
            let itemId: String
        }
        let response: APIResponse<ItemDTO> = try await apiClient
            .perform(operation: APIOperation.itemLike, params: Params(itemId: itemID))
        try appModel.addLikedItem(inResponse: response)
    }

    func unlikeItem(itemID: String) async throws {
        struct Params: Encodable {
            let itemId: String
        }
        let response: APIResponse<ItemDTO> = try await apiClient
            .perform(operation: APIOperation.itemUnlike, params: Params(itemId: itemID))
        try appModel.removeUnlikedItem(inResponse: response)
    }

    func saveItem(itemID: String) async throws {
        struct Params: Encodable {
            let itemId: String
        }
        let response: APIResponse<ItemDTO> = try await apiClient
            .perform(operation: APIOperation.itemSave, params: Params(itemId: itemID))
        try appModel.addSavedItem(inResponse: response)
    }

    func unsaveItem(itemID: String) async throws {
        struct Params: Encodable {
            let itemId: String
        }
        let response: APIResponse<ItemDTO> = try await apiClient
            .perform(operation: APIOperation.itemUnsave, params: Params(itemId: itemID))
        try appModel.removeUnsavedItem(inResponse: response)
    }
}
