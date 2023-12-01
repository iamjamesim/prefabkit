import Combine
import Foundation

/// An `AppObjectProvider` that converts DTOs in an API response to app objects containing the latest values in
/// the API response.
final class APIResponseProcessor<T: AppObject>: AppObjectProvider {
    private let data: T.DTO
    private let includedDTOs: [AppObjectKey: any AppObjectDTO]
    private let objectStoreProxy: AppObjectStore.StoreProxy
    private var updatedObjectIDs = Set<AppObjectKey>()

    /// Creates a new `APIResponseProcessor` instance.
    /// - Parameters:
    ///   - allDTOs: All DTOs in an API response.
    ///   - objectStoreProxy: A proxy for the object store.
    init(
        response: APIResponse<T.DTO>,
        objectStoreProxy: AppObjectStore.StoreProxy
    ) {
        self.data = response.data
        self.includedDTOs = response.included?
            .map { $0.dto }
            .reduce(into: [AppObjectKey: any AppObjectDTO](), { result, dto in
                result[dto.globalObjectKey] = dto
            }) ?? [:]
        self.objectStoreProxy = objectStoreProxy
    }

    func dataObject() throws -> CurrentValueSubject<T, Never> {
        let newValue = try T(dto: data, relatedObjectProvider: self)
        return objectStoreProxy.mergeValue(id: data.id, newValue: newValue)
    }

    func appObject<U: AppObject>(forID objectID: String) throws -> CurrentValueSubject<U, Never> {
        let objectKey = AppObjectKey(objectType: U.objectType, objectID: objectID)
        guard let object: CurrentValueSubject<U, Never> = objectStoreProxy.value(forID: objectID) else {
            return try mergeValue(forKey: objectKey)
        }
        guard updatedObjectIDs.contains(objectKey) else {
            return try mergeValue(forKey: objectKey)
        }
        return object
    }

    private func mergeValue<U: AppObject>(forKey objectKey: AppObjectKey) throws -> CurrentValueSubject<U, Never> {
        updatedObjectIDs.insert(objectKey)

        // Find the DTO for the key.
        guard let dto = includedDTOs[objectKey] as? U.DTO else {
            throw AppObjectProviderError.objectNotIncluded
        }

        // Create the object, and merge it into the object store.
        let newValue = try U(dto: dto, relatedObjectProvider: self)
        return objectStoreProxy.mergeValue(id: objectKey.objectID, newValue: newValue)
    }
}

enum AppObjectProviderError: Error {
    /// Object referenced in the API response was not included in the response.
    case objectNotIncluded
}

extension AppObjectDTO {
    fileprivate var globalObjectKey: AppObjectKey {
        AppObjectKey(objectType: Object.objectType, objectID: id)
    }
}
