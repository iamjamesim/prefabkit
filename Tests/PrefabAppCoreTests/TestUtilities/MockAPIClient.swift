@testable import PrefabAppCore

import Foundation
import PrefabAppCoreInterface

final class MockAPIClient: APIClientProtocol {
    private(set) var performCalled = false
    var performParams: (APIOperation, Any)?
    var performRV: Any?
    func perform<T: Encodable, U: Decodable>(operation: APIOperation, params: T) async throws -> U {
        guard let performRV = performRV as? U else {
            throw MockError.nilReturnValue
        }
        performCalled = true
        performParams = (operation, params)
        return performRV
    }

    private(set) var performVoidCalled = false
    var performVoidParams: (APIOperation, Any)?
    func perform<T: Encodable>(operation: APIOperation, params: T) async throws {
        performVoidCalled = true
        performVoidParams = (operation, params)
    }

    private(set) var performWithMultipartRequestCalled = false
    var performWithMultipartRequestParams: (APIOperation, MultipartRequest)?
    var performWithMultipartRequestRV: Any?
    func perform<T: Decodable>(
        operation: APIOperation,
        multipartRequest: MultipartRequest
    ) async throws -> T {
        guard let performWithMultipartRequestRV = performWithMultipartRequestRV as? T else {
            throw MockError.nilReturnValue
        }
        performWithMultipartRequestCalled = true
        performWithMultipartRequestParams = (operation, multipartRequest)
        return performWithMultipartRequestRV
    }

    private(set) var downloadCalled = false
    var downloadRV: Data?
    func download(fromPath path: String) async throws -> Data {
        guard let downloadRV else {
            throw MockError.nilReturnValue
        }
        downloadCalled = true
        return downloadRV
    }
}
