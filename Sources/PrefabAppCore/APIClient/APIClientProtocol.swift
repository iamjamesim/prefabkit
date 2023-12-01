import Foundation
import PrefabAppCoreInterface

/// A protocol for the primary API client of an app.
public protocol APIClientProtocol {
    /// Performs an API operation.
    ///
    /// - Parameters:
    ///     - operation: An API operation to perform.
    ///     - params: Request parameters.
    /// - Returns: An API response.
    func perform<T: Encodable, U: Decodable>(operation: APIOperation, params: T) async throws -> U

    /// Performs an API operation.
    ///
    /// - Parameters:
    ///     - operation: An API operation to perform.
    ///     - params: Request parameters.
    func perform<T: Encodable>(operation: APIOperation, params: T) async throws

    /// Performs an API operation with a multipart request.
    ///
    /// - Parameters:
    ///     - operation: An API operation to perform.
    ///     - multipartRequest: A multipart request.
    /// - Returns: An API response.
    func perform<T: Decodable>(operation: APIOperation, multipartRequest: MultipartRequest) async throws -> T

    /// Downloads a file from a given path in storage.
    ///
    /// - Parameter path: A file path in storage.
    /// - Returns: The downloaded file data.
    func download(fromPath path: String) async throws -> Data
}

private struct NoParams: Encodable {}

extension APIClientProtocol {
    /// Performs an API operation.
    ///
    /// - Parameters:
    ///     - operation: An API operation to perform.
    /// - Returns: An API response.
    func perform<T: Decodable>(operation: APIOperation) async throws -> T {
        try await perform(operation: operation, params: NoParams())
    }
}

public enum APIClientError: Error {
    case fileNotFound
}
