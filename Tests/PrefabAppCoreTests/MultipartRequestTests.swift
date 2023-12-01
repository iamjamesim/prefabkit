import XCTest
@testable import PrefabAppCore

import PrefabAppCoreInterface

final class MultipartRequestTests: XCTestCase {
    func testHeaders() {
        let boundary = "Boundary-1234"
        let request = MultipartRequest(boundary: boundary)
        XCTAssertEqual(
            request.headers,
            ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        )
    }

    func testBodyWithFields() async throws {
        let boundary = "Boundary-1234"
        var request = MultipartRequest(boundary: boundary)
        request.addField(.init(name: "name", value: "value"))
        request.addField(.init(name: "name2", value: "value2"))

        let requestBody = String(data: request.body, encoding: .utf8)
        let expectedBody = "--Boundary-1234\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\nvalue\r\n--Boundary-1234\r\nContent-Disposition: form-data; name=\"name2\"\r\n\r\nvalue2\r\n--Boundary-1234--\r\n"
        XCTAssertEqual(requestBody, expectedBody)
    }

    func testBodyWithFiles() async throws {
        let boundary = "Boundary-1234"
        var request = MultipartRequest(boundary: boundary)
        request.addFile(
            .init(
                partName: "partName",
                fileName: "fileName",
                mimeType: .jpeg,
                fileData: "fileData".data(using: .utf8)!
            )
        )
        request.addFile(
            .init(
                partName: "partName2",
                fileName: "fileName2",
                mimeType: .png,
                fileData: "fileData".data(using: .utf8)!
            )
        )

        let requestBody = String(data: request.body, encoding: .utf8)
        let expectedBody = "--Boundary-1234\r\nContent-Disposition: form-data; name=\"partName\"; filename=\"fileName\"\r\nContent-Type: image/jpeg\r\n\r\nfileData\r\n--Boundary-1234\r\nContent-Disposition: form-data; name=\"partName2\"; filename=\"fileName2\"\r\nContent-Type: image/png\r\n\r\nfileData\r\n--Boundary-1234--\r\n"
        XCTAssertEqual(requestBody, expectedBody)
    }

    func testBodyWithFieldsAndFiles() async throws {
        let boundary = "Boundary-1234"
        var request = MultipartRequest(boundary: boundary)
        request.addField(.init(name: "name", value: "value"))
        request.addFile(
            .init(
                partName: "partName",
                fileName: "fileName",
                mimeType: .jpeg,
                fileData: "fileData".data(using: .utf8)!
            )
        )
        request.addField(.init(name: "name2", value: "value2"))
        request.addFile(
            .init(
                partName: "partName2",
                fileName: "fileName2",
                mimeType: .png,
                fileData: "fileData".data(using: .utf8)!
            )
        )

        let requestBody = String(data: request.body, encoding: .utf8)
        let expectedBody = "--Boundary-1234\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\nvalue\r\n--Boundary-1234\r\nContent-Disposition: form-data; name=\"partName\"; filename=\"fileName\"\r\nContent-Type: image/jpeg\r\n\r\nfileData\r\n--Boundary-1234\r\nContent-Disposition: form-data; name=\"name2\"\r\n\r\nvalue2\r\n--Boundary-1234\r\nContent-Disposition: form-data; name=\"partName2\"; filename=\"fileName2\"\r\nContent-Type: image/png\r\n\r\nfileData\r\n--Boundary-1234--\r\n"
        XCTAssertEqual(requestBody, expectedBody)
    }
}
