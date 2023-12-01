import XCTest
@testable import PrefabAppCore

import Combine

final class APIResponseProcessorTests: XCTestCase {
    func testGetAppObject_alreadyProcessedObject() throws {
        // Test data.
        let existingObjectDTO = TestItemDTO(id: "1", title: "Hello, World!", body: "Lorem ipsum dolor sit amet.")
        let existingObject = try TestItem(dto: existingObjectDTO, relatedObjectProvider: TestNoopObjectProvider())
        let dataDTO = TestItemAuthorDTO(id: "1", name: "John Doe")
        let dtoToProcess = TestItemDTO(id: "1", title: "Goodbye, World!", body: "Dolor sit amet.")
        let response = APIResponse(data: dataDTO, included: [.init(dto: dtoToProcess)])

        let store = AppObjectStore()
        try store.performWithinTransaction { proxy in
            var storeObject = proxy.mergeValue(id: existingObject.id, newValue: existingObject)

            // Test that the response processor updates the store when getting an unprocessed object.
            let responseProcessor = APIResponseProcessor<TestItemAuthor>(response: response, objectStoreProxy: proxy)
            var responseObject: CurrentValueSubject<TestItem, Never> = try responseProcessor.appObject(forID: dtoToProcess.id)
            XCTAssertIdentical(responseObject, storeObject)
            XCTAssertEqual(responseObject.value.id, dtoToProcess.id)
            XCTAssertEqual(responseObject.value.title, dtoToProcess.title)
            XCTAssertEqual(responseObject.value.body, dtoToProcess.body)

            // Revert the value.
            storeObject = proxy.mergeValue(id: existingObject.id, newValue: existingObject)
            XCTAssertEqual(responseObject.value.id, existingObjectDTO.id)
            XCTAssertEqual(responseObject.value.title, existingObjectDTO.title)
            XCTAssertEqual(responseObject.value.body, existingObjectDTO.body)

            // Test that the response processor does not update the store when getting an already processed object.
            responseObject = try responseProcessor.appObject(forID: dtoToProcess.id)
            XCTAssertEqual(responseObject.value.id, existingObjectDTO.id)
            XCTAssertEqual(responseObject.value.title, existingObjectDTO.title)
            XCTAssertEqual(responseObject.value.body, existingObjectDTO.body)
        }
    }

    func testGetAppObject_missingDTO() throws {
        // Test data.
        let dataDTO = TestItemAuthorDTO(id: "1", name: "John Doe")
        let dtoToProcess = TestItemDTO(id: "1", title: "Hello, World!", body: "Lorem ipsum dolor sit amet.")
        let response = APIResponse(data: dataDTO, included: [.init(dto: dtoToProcess)])

        let store = AppObjectStore()
        try store.performWithinTransaction { proxy in
            // Test that the response processor throws an error when getting an object that is not included in the API response.
            let responseProcessor = APIResponseProcessor<TestItemAuthor>(response: response, objectStoreProxy: proxy)
            XCTAssertThrowsError(try {
                let _: CurrentValueSubject<TestItem, Never> = try responseProcessor.appObject(forID: "2")
            }()) { error in
                XCTAssertEqual(error as? AppObjectProviderError, AppObjectProviderError.objectNotIncluded)
            }
        }
    }
}
