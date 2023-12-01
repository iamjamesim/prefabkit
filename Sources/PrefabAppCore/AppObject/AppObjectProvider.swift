import Combine
import Foundation

/// A protocol that provides related app objects to object initializers during API response processing.
protocol AppObjectProvider {
    /// Returns an app object given an app object ID.
    ///
    /// - Parameters:
    ///   - id: An app object ID.
    /// - Throws: An error on object retrieval failure.
    /// - Returns: A `CurrentValueSubject` containing an app object.
    func appObject<U: AppObject>(forID objectID: String) throws -> CurrentValueSubject<U, Never>
}
