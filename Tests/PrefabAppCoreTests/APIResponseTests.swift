import XCTest
@testable import PrefabAppCore

final class APIResponseTests: XCTestCase {
    override class func setUp() {
        AppObjectType.setDTOTypeOverride(TestItemAuthorDTO.self, forObjectType: .userProfile)
    }

    override class func tearDown() {
        AppObjectType.setDTOTypeOverride(nil, forObjectType: .userProfile)
    }

    private struct EmptyDecodable: Decodable {}

    func testEmptyResponse() throws {
        let json = """
        {
            "data": null
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(APIResponse<EmptyDecodable?>.self, from: json)
        XCTAssertNil(response.data)
        XCTAssertNil(response.included)
    }

    func testDecodingSingleObject() throws {
        let json = """
        {
            "data": {
                "id": "1",
                "type": "item",
                "title": "Hello, World!",
                "body": "Lorem ipsum dolor sit amet."
            }
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(APIResponse<TestItemDTO>.self, from: json)
        XCTAssertNil(response.included)

        let item = response.data
        XCTAssertEqual(item.id, "1")
        XCTAssertEqual(item.title, "Hello, World!")
        XCTAssertEqual(item.body, "Lorem ipsum dolor sit amet.")
    }

    func testDecodingArrayOfObjects() throws {
        let json = """
        {
            "data": [
                {
                    "id": "1",
                    "type": "item",
                    "title": "Hello, World!",
                    "body": "Lorem ipsum dolor sit amet."
                },
                {
                    "id": "2",
                    "type": "item",
                    "title": "Goodbye, World!",
                    "body": "Dolor sit amet."
                }
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(APIResponse<[TestItemDTO]>.self, from: json)
        XCTAssertNil(response.included)

        let items = response.data
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, "1")
        XCTAssertEqual(items[0].title, "Hello, World!")
        XCTAssertEqual(items[0].body, "Lorem ipsum dolor sit amet.")
        XCTAssertEqual(items[1].id, "2")
        XCTAssertEqual(items[1].title, "Goodbye, World!")
        XCTAssertEqual(items[1].body, "Dolor sit amet.")
    }

    func testDecodingSingleObjectWithIncludedObjects() throws {
        let json = """
        {
            "data": {
                "id": "1",
                "type": "item",
                "title": "Hello, World!",
                "body": "Lorem ipsum dolor sit amet."
            },
            "included": [
                {
                    "id": "1",
                    "type": "userProfile",
                    "name": "John Doe"
                }
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(APIResponse<TestItemDTO>.self, from: json)

        let item = response.data
        XCTAssertEqual(item.id, "1")
        XCTAssertEqual(item.title, "Hello, World!")
        XCTAssertEqual(item.body, "Lorem ipsum dolor sit amet.")

        XCTAssertEqual(response.included?.count, 1)
        guard let author = response.included?.first?.dto as? TestItemAuthorDTO else {
            XCTFail("Expected included DTO type not found.")
            return
        }
        XCTAssertEqual(author.id, "1")
        XCTAssertEqual(author.name, "John Doe")
    }

    func testDecodingArrayOfObjectsWithIncludedObjects() throws {
        let json = """
        {
            "data": [
                {
                    "id": "1",
                    "type": "item",
                    "title": "Hello, World!",
                    "body": "Lorem ipsum dolor sit amet.",
                    "relationships": {
                        "author": {
                            "data": {
                                "id": "1",
                                "type": "userProfile"
                            }
                        }
                    }
                },
                {
                    "id": "2",
                    "type": "item",
                    "title": "Goodbye, World!",
                    "body": "Dolor sit amet.",
                    "relationships": {
                        "author": {
                            "data": {
                                "id": "2",
                                "type": "userProfile"
                            }
                        }
                    }
                }
            ],
            "included": [
                {
                    "id": "1",
                    "type": "userProfile",
                    "name": "John Doe"
                },
                {
                    "id": "2",
                    "type": "userProfile",
                    "name": "Jane Doe"
                }
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(APIResponse<[TestItemDTO]>.self, from: json)

        let items = response.data
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, "1")
        XCTAssertEqual(items[0].title, "Hello, World!")
        XCTAssertEqual(items[0].body, "Lorem ipsum dolor sit amet.")
        XCTAssertEqual(items[1].id, "2")
        XCTAssertEqual(items[1].title, "Goodbye, World!")
        XCTAssertEqual(items[1].body, "Dolor sit amet.")

        XCTAssertEqual(response.included?.count, 2)
        guard let author1 = response.included?[0].dto as? TestItemAuthorDTO,
        let author2 = response.included?[1].dto as? TestItemAuthorDTO else {
            XCTFail("Expected included DTO type not found.")
            return
        }
        XCTAssertEqual(author1.id, "1")
        XCTAssertEqual(author1.name, "John Doe")
        XCTAssertEqual(author2.id, "2")
        XCTAssertEqual(author2.name, "Jane Doe")
    }

    func testDecodingSingleObjectError() throws {
        do {
            let json = """
            {
                "data": {
                    "id": "1",
                    "type": "item"
                }
            }
            """.data(using: .utf8)!
            _ = try JSONDecoder().decode(APIResponse<TestItemDTO>.self, from: json)
            XCTFail("Expected decoding error to be thrown.")
        } catch DecodingError.keyNotFound {
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    func testDecodingArrayOfObjectsError() throws {
        do {
            let json = """
            {
                "data": [
                    {
                        "id": "1",
                        "type": "item"
                    },
                    {
                        "id": "2",
                        "type": "item"
                    }
                ]
            }
            """.data(using: .utf8)!

            _ = try JSONDecoder().decode(APIResponse<[TestItemDTO]>.self, from: json)
            XCTFail("Expected decoding error to be thrown.")
        } catch DecodingError.keyNotFound {
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    func testDecodingUnknownPageType() throws {
        let json = """
        {
            "data": {
                "id": "1",
                "type": "pageContent",
                "query": "newType",
                "pageContext": {},
                "collectionIds": []
            }
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(APIResponse<PageContentDTO>.self, from: json)
        XCTAssertEqual(response.data.query, .unknown)
    }
}
