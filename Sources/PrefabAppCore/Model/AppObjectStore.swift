import Combine
import Foundation

/// A centralized store for objects shared throughout the application.
final class AppObjectStore {
    /// A proxy for the store that can be used to perform operations on the store.
    final class StoreProxy {
        fileprivate let store: AppObjectStore

        /// Creates a new `StoreProxy` instance.
        /// - Parameter store: The store to proxy.
        init(store: AppObjectStore) {
            self.store = store
        }

        /// Returns an object with the specified ID, if it exists.
        /// - Parameter id: The ID of the object to retrieve.
        /// - Returns: A `CurrentValueSubject` containing the object, if it exists.
        func value<T: AppObject>(forID id: String) -> CurrentValueSubject<T, Never>? {
            store.objects[ObjectIdentifier(T.self)]?[id] as? CurrentValueSubject<T, Never>
        }

        /// Merges the new value into the store.
        /// - Parameters:
        ///   - id: The ID of the object to merge.
        ///   - newValue: The new value to merge.
        /// - Returns: A `CurrentValueSubject` containing the merged object.
        func mergeValue<T: AppObject>(id: String, newValue: T) -> CurrentValueSubject<T, Never> {
            guard let existingObject: CurrentValueSubject<T, Never> = value(forID: id) else {
                let object = CurrentValueSubject<T, Never>(newValue)
                if store.objects[ObjectIdentifier(T.self)] == nil {
                    store.objects[ObjectIdentifier(T.self)] = [:]
                }
                store.objects[ObjectIdentifier(T.self)]?[id] = object
                return object
            }
            existingObject.send(newValue)
            return existingObject
        }

        /// Performs updates on all objects of the specified type.
        /// - Parameters:
        ///   - updates: The updates to perform on the objects.
        func performObjectUpdates<U: AppObject>(_ updates: ([CurrentValueSubject<U, Never>]) throws -> Void) throws {
            if let targetObjects = store.objects[ObjectIdentifier(U.self)] as? [String: CurrentValueSubject<U, Never>] {
                try updates(Array(targetObjects.values))
            }
        }
    }

    private let queue = DispatchQueue(label: "dev.prefabkit.AppObjectStore", attributes: .concurrent)

    private var objects = [ObjectIdentifier: [String: Any]]()

    /// Performs a store operation within a transaction.
    /// - Parameter body: The operation to perform.
    /// - Returns: The result of the operation.
    func performWithinTransaction<T>(_ body: (StoreProxy) throws -> T) throws -> T {
        try queue.sync(flags: .barrier) {
            try body(StoreProxy(store: self))
        }
    }
}
