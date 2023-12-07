import XCTest
@testable import PrefabAppCore

import PrefabAppCoreInterface

final class UserProfileInitializerTests: XCTestCase {
    private var apiClient: MockAPIClient!
    private var userProfileInitializer: UserProfileInitializer!

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
        userProfileInitializer = UserProfileInitializer(apiClient: apiClient)
    }

    override func tearDown() {
        apiClient = nil
        userProfileInitializer = nil
        super.tearDown()
    }

    func testCurrentUserProfile() async throws {
        apiClient.performRV = APIResponse(
            data: TestData.profileDTO as UserProfileDTO?,
            included: nil
        )
        _ = try await userProfileInitializer.currentUserProfile()
        XCTAssertTrue(apiClient.performCalled)
    }

    func testCurrentUserProfile_nilResponse() async throws {
        apiClient.performRV = APIResponse(
            data: nil as UserProfileDTO?,
            included: nil
        )
        do {
            _ = try await userProfileInitializer.currentUserProfile()
            XCTFail("Expected an error to be thrown.")
        } catch UserProfileInitializerError.profileNotFound {
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }

    func testCreateUserProfile() async throws {
        apiClient.performRV = APIResponse(
            data: TestData.profileDTO,
            included: nil
        )
        _ = try await userProfileInitializer.createUserProfile(
            username: TestData.profileDTO.username,
            displayName: TestData.profileDTO.displayName
        )
        XCTAssertTrue(apiClient.performCalled)
        XCTAssertEqual(apiClient.performParams?.0, APIOperation.userProfileCreate)
    }
}
