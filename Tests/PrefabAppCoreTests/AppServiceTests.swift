import XCTest
@testable import PrefabAppCore

import PrefabAppCoreInterface

final class AppServiceTests: XCTestCase {
    private static let testItemResponse: APIResponse<ItemDTO> = {
        return APIResponse(
            data: TestData.itemDTO,
            included: nil
        )
    }()

    private var apiClient: MockAPIClient!
    private var appModel: MockAppModel!
    private var appService: AppService!

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
        appModel = MockAppModel()
        appService = AppService(
            appID: "test",
            apiClient: apiClient,
            appModel: appModel
        )
    }

    override func tearDown() {
        apiClient = nil
        appModel = nil
        appService = nil
        super.tearDown()
    }

    func testFetchAppSpec() async throws {
        apiClient.performRV = AppSpec(pages: [], destinationPages: [])
        _ = try await appService.appSpec()
        XCTAssertTrue(apiClient.performCalled)
    }

    func testFetchPageContent() async throws {
        let pageContentQuery = PageContentQuery.creatorItems
        let pageContext = PageContext(pageID: nil, objectID: nil)
        let performRV: APIResponse<PageContentDTO> = APIResponse(
            data: PageContentDTO(
                query: pageContentQuery,
                pageId: pageContext.pageID,
                objectId: pageContext.objectID,
                collectionIds: []
            ),
            included: nil
        )
        apiClient.performRV = performRV
        appModel.upsertPageContentRV = PageContentSubject(
            PageContent(
                query: pageContentQuery,
                pageContext: pageContext,
                collections: []
            )
        )

        let _: PageContentSubject = try await appService.pageContent(query: pageContentQuery, pageContext: pageContext)
        XCTAssertTrue(apiClient.performCalled)
        XCTAssertEqual(apiClient.performParams?.0, APIOperation.pageContent)
        XCTAssertTrue(appModel.upsertPageContentCalled)
    }

    func testDownloadImage() async throws {
        apiClient.downloadRV = UIImage(systemName: "xmark")?.pngData()

        _ = try await appService.downloadImage(atPath: "")
        XCTAssertTrue(apiClient.downloadCalled)
    }

    func testDownloadImage_invalidData() async throws {
        apiClient.downloadRV = "Not an image".data(using: .utf8)
        do {
            _ = try await appService.downloadImage(atPath: "")
            XCTFail("Expected an error to be thrown.")
        } catch {
        }
    }

    func testCreateItem() async throws {
        apiClient.performWithMultipartRequestRV = Self.testItemResponse
        try await appService.createItem(withRequest: MultipartRequest(), itemType: .socialPost, collectionID: nil)
        XCTAssertTrue(apiClient.performWithMultipartRequestCalled)
        XCTAssertEqual(apiClient.performWithMultipartRequestParams?.0, APIOperation.itemCreate)
        XCTAssertTrue(appModel.addItemCalled)
    }

    func testCreateCollectionItem() async throws {
        apiClient.performWithMultipartRequestRV = Self.testItemResponse
        try await appService.createItem(withRequest: MultipartRequest(), itemType: .product, collectionID: "1")
        XCTAssertTrue(apiClient.performWithMultipartRequestCalled)
        XCTAssertEqual(apiClient.performWithMultipartRequestParams?.0, APIOperation.itemCreate)
        XCTAssertTrue(appModel.addCollectionItemCalled)
    }

    func testDeleteItem() async throws {
        try await appService.deleteItem(itemID: "1")
        XCTAssertTrue(apiClient.performVoidCalled)
        XCTAssertEqual(apiClient.performVoidParams?.0, APIOperation.itemDelete)
        XCTAssertTrue(appModel.removeItemCalled)
    }

    func testCreateItemCollection() async throws {
        let dto = ItemCollectionDTO(id: "1", name: "Test Collection", layout: .verticalList, itemIds: [])
        let performRV: APIResponse<ItemCollectionDTO> = APIResponse(
            data: dto,
            included: nil
        )
        apiClient.performRV = performRV

        try await appService.createItemCollection(name: "Test Collection")
        XCTAssertTrue(apiClient.performCalled)
        XCTAssertEqual(apiClient.performParams?.0, APIOperation.itemCollectionCreate)
        XCTAssertTrue(appModel.addCollectionCalled)
    }

    func testDeleteItemCollection() async throws {
        try await appService.deleteItemCollection(collectionID: "1")
        XCTAssertTrue(apiClient.performVoidCalled)
        XCTAssertEqual(apiClient.performVoidParams?.0, APIOperation.itemCollectionDelete)
        XCTAssertTrue(appModel.removeCollectionCalled)
    }

    func testSaveItem() async throws {
        apiClient.performRV = Self.testItemResponse
        try await appService.saveItem(itemID: "1")
        XCTAssertTrue(apiClient.performCalled)
        XCTAssertEqual(apiClient.performParams?.0, APIOperation.itemSave)
        XCTAssertTrue(appModel.addSavedItemCalled)
    }

    func testUnsaveItem() async throws {
        apiClient.performRV = Self.testItemResponse
        try await appService.unsaveItem(itemID: "1")
        XCTAssertTrue(apiClient.performCalled)
        XCTAssertEqual(apiClient.performParams?.0, APIOperation.itemUnsave)
        XCTAssertTrue(appModel.removeUnsavedItemCalled)
    }

    func testLikeItem() async throws {
        apiClient.performRV = Self.testItemResponse
        try await appService.likeItem(itemID: "1")
        XCTAssertTrue(apiClient.performCalled)
        XCTAssertEqual(apiClient.performParams?.0, APIOperation.itemLike)
        XCTAssertTrue(appModel.addLikedItemCalled)
    }

    func testUnlikeItem() async throws {
        apiClient.performRV = Self.testItemResponse
        try await appService.unlikeItem(itemID: "1")
        XCTAssertTrue(apiClient.performCalled)
        XCTAssertEqual(apiClient.performParams?.0, APIOperation.itemUnlike)
        XCTAssertTrue(appModel.removeLikedItemCalled)
    }
}
