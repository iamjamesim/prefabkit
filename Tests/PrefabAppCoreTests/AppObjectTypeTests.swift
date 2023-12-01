import XCTest
@testable import PrefabAppCore

final class AppObjectTypeTests: XCTestCase {
    func testTypeDTOAssociation() {
        for appObjectType in AppObjectType.allCases {
            XCTAssertEqual(appObjectType.dtoType.objectType, appObjectType)
        }
    }
}
