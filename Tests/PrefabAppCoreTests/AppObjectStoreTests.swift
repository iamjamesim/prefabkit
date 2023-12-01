import XCTest
@testable import PrefabAppCore

import Combine
import PrefabAppCoreInterface

final class AppObjectStoreTests: XCTestCase {
    func testEmptyStore() throws {
        let store = AppObjectStore()

        // Test retrieving from an empty store.
        let nilItem: CurrentValueSubject<TestItem, Never>? = try store.performWithinTransaction { proxy in
            return proxy.value(forID: "1")
        }
        XCTAssertNil(nilItem)
    }

    func testMergeNewValue() throws {
        let store = AppObjectStore()

        // Test data.
        let newItemDTO = TestItemDTO(id: "1", title: "Hello, World!", body: "Lorem ipsum dolor sit amet.")

        // Test merging a new object.
        let newItem = try TestItem(dto: newItemDTO, relatedObjectProvider: TestNoopObjectProvider())
        let mergedNewItem: CurrentValueSubject<TestItem, Never> = try store.performWithinTransaction { proxy in
            return proxy.mergeValue(id: newItem.id, newValue: newItem)
        }
        XCTAssertEqual(mergedNewItem.value.id, newItemDTO.id)
        XCTAssertEqual(mergedNewItem.value.title, newItemDTO.title)
        XCTAssertEqual(mergedNewItem.value.body, newItemDTO.body)

        // Test retrieving objects that shouldn't exist.
        let sameTypeDifferentID: CurrentValueSubject<TestItem, Never>? = try store.performWithinTransaction { proxy in
            return proxy.value(forID: "2")
        }
        XCTAssertNil(sameTypeDifferentID)
        let sameIDDifferentType: CurrentValueSubject<TestItemAuthor, Never>? = try store.performWithinTransaction { proxy in
            return proxy.value(forID: newItem.id)
        }
        XCTAssertNil(sameIDDifferentType)
    }

    func testMergeExistingValue() throws {
        let store = AppObjectStore()

        // Test data.
        let newItemDTO = TestItemDTO(id: "1", title: "Hello, World!", body: "Lorem ipsum dolor sit amet.")
        let existingItemDTO = TestItemDTO(id: "1", title: "Goodbye, World!", body: "Dolor sit amet.")

        // Test merging a new object.
        let newItem = try TestItem(dto: newItemDTO, relatedObjectProvider: TestNoopObjectProvider())
        let mergedNewItem: CurrentValueSubject<TestItem, Never> = try store.performWithinTransaction { proxy in
            return proxy.mergeValue(id: newItem.id, newValue: newItem)
        }
        XCTAssertEqual(mergedNewItem.value.id, newItemDTO.id)
        XCTAssertEqual(mergedNewItem.value.title, newItemDTO.title)
        XCTAssertEqual(mergedNewItem.value.body, newItemDTO.body)

        // Test values on subject updates.
        let subjectUpdatesExpectation = self.expectation(description: "Subject updates twice")
        var count = 0
        let cancellable = mergedNewItem.sink { value in
            if count == 0 {
                XCTAssertEqual(value.id, newItemDTO.id)
                XCTAssertEqual(value.title, newItemDTO.title)
                XCTAssertEqual(value.body, newItemDTO.body)
            } else if count == 1 {
                XCTAssertEqual(value.id, existingItemDTO.id)
                XCTAssertEqual(value.title, existingItemDTO.title)
                XCTAssertEqual(value.body, existingItemDTO.body)
                subjectUpdatesExpectation.fulfill()
            }
            count += 1
        }

        // Test merging an existing value.
        let existingItem = try TestItem(dto: existingItemDTO, relatedObjectProvider: TestNoopObjectProvider())
        let mergedExistingItem: CurrentValueSubject<TestItem, Never> = try store.performWithinTransaction { proxy in
            return proxy.mergeValue(id: existingItem.id, newValue: existingItem)
        }
        XCTAssertIdentical(mergedNewItem, mergedExistingItem)
        XCTAssertEqual(mergedExistingItem.value.id, existingItemDTO.id)
        XCTAssertEqual(mergedExistingItem.value.title, existingItemDTO.title)
        XCTAssertEqual(mergedExistingItem.value.body, existingItemDTO.body)


        wait(for: [subjectUpdatesExpectation], timeout: 1.0)
        cancellable.cancel()
    }

    func testPerformObjectUpdates() throws {
        let store = AppObjectStore()

        // Test performing updates on objects that don't exist.
        try store.performWithinTransaction { proxy in
            try proxy.performObjectUpdates { (objects: [CurrentValueSubject<TestItem, Never>]) in
                XCTAssertEqual(objects.count, 0)
            }
        }

        // Test performing updates on objects of a specific type.
        let item1DTO = TestItemDTO(id: "1", title: "Hello, World!", body: "Lorem ipsum dolor sit amet.")
        let item1 = try TestItem(dto: item1DTO, relatedObjectProvider: TestNoopObjectProvider())
        let item2DTO = TestItemDTO(id: "2", title: "Goodbye, World!", body: "Dolor sit amet.")
        let item2 = try TestItem(dto: item2DTO, relatedObjectProvider: TestNoopObjectProvider())
        let mergedItems = try store.performWithinTransaction { proxy in
            return [
                proxy.mergeValue(id: item1.id, newValue: item1),
                proxy.mergeValue(id: item2.id, newValue: item2)
            ]
        }
        let authorDTO = TestItemAuthorDTO(id: "1", name: "John Doe")
        let author = try TestItemAuthor(dto: authorDTO, relatedObjectProvider: TestNoopObjectProvider())
        _ = try store.performWithinTransaction { proxy in
            proxy.mergeValue(id: author.id, newValue: author)
        }

        let updatedTitle = "Hello, Goodbye"
        try store.performWithinTransaction { proxy in
            try proxy.performObjectUpdates { (objects: [CurrentValueSubject<TestItem, Never>]) in
                XCTAssertEqual(objects.count, 2)

                for object in objects {
                    let updatedDTO = TestItemDTO(id: object.id, title: updatedTitle, body: object.value.body)
                    let updatedItem = try TestItem(dto: updatedDTO, relatedObjectProvider: TestNoopObjectProvider())
                    object.value = updatedItem
                }
            }
        }
        for item in mergedItems {
            XCTAssertEqual(item.value.title, updatedTitle)
        }
    }

    func testThreadSafety() throws {
        let store = AppObjectStore()

        let serialQueue = DispatchQueue(label: "dev.prefabkit.AppObjectStoreTests.serial")
        let concurrentQueue = DispatchQueue(label: "dev.prefabkit.AppObjectStoreTests.concurrent", attributes: .concurrent)
        let group = DispatchGroup()

        // Test thread safety when merging the same value simultaneously.
        let itemDTO = TestItemDTO(id: "1", title: "Hello, World!", body: "Lorem ipsum dolor sit amet.")
        let item = try TestItem(dto: itemDTO, relatedObjectProvider: TestNoopObjectProvider())
        var firstMergeResult: CurrentValueSubject<TestItem, Never>?
        for _ in 1...100 {
            group.enter()
            concurrentQueue.async {
                do {
                    let currentMergeResult: CurrentValueSubject<TestItem, Never> = try store.performWithinTransaction { proxy in
                        return proxy.mergeValue(id: item.id, newValue: item)
                    }
                    serialQueue.async {
                        if firstMergeResult == nil {
                            firstMergeResult = currentMergeResult
                        } else {
                            XCTAssertIdentical(firstMergeResult, currentMergeResult)
                        }
                    }
                } catch {
                    XCTFail("Unexpected error: \(error)")
                }
                group.leave()
            }
        }
        group.wait()
    }
}
