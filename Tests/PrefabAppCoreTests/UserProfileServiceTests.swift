import XCTest
@testable import PrefabAppCore

import PrefabAppCoreInterface

final class UserProfileServiceTests: XCTestCase {
    private var apiClient: MockAPIClient!
    private var appModel: MockAppModel!
    private var userProfileService: UserProfileService!

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
        appModel = MockAppModel()
        userProfileService = UserProfileService(apiClient: apiClient, appModel: appModel)
    }

    override func tearDown() {
        apiClient = nil
        appModel = nil
        userProfileService = nil
        super.tearDown()
    }

    func testUserProfile_profileExistsInAppModel() async throws {
        appModel.userProfileRV = TestData.profileSubject
        _ = try await userProfileService.userProfile(userID: TestData.profileSubject.id)
        XCTAssertFalse(apiClient.performCalled)
        XCTAssertTrue(appModel.userProfileCalled)
    }

    func testUserProfile_profileDoesNotExistInAppModel() async throws {
        apiClient.performRV = APIResponse(
            data: TestData.profileDTO,
            included: nil
        )
        appModel.userProfileRV = nil
        appModel.upsertProfileRV = TestData.profileSubject
        _ = try await userProfileService.userProfile(userID: TestData.profileSubject.id)
        XCTAssertTrue(apiClient.performCalled)
        XCTAssertEqual(apiClient.performParams?.0, APIOperation.userProfile)
        XCTAssertTrue(appModel.upsertProfileCalled)
    }

    func testUpdateUsername() async throws {
        apiClient.performRV = APIResponse(
            data: TestData.profileDTO,
            included: nil
        )
        appModel.upsertProfileRV = TestData.profileSubject
        _ = try await userProfileService.updateUsername(TestData.profileDTO.username)
        XCTAssertTrue(apiClient.performCalled)
        XCTAssertEqual(apiClient.performParams?.0, APIOperation.userProfileUpdate)
        XCTAssertTrue(appModel.upsertProfileCalled)
    }

    func testUpdateDisplayName() async throws {
        apiClient.performRV = APIResponse(
            data: TestData.profileDTO,
            included: nil
        )
        appModel.upsertProfileRV = TestData.profileSubject
        _ = try await userProfileService.updateDisplayName(TestData.profileDTO.username)
        XCTAssertTrue(apiClient.performCalled)
        XCTAssertEqual(apiClient.performParams?.0, APIOperation.userProfileUpdate)
        XCTAssertTrue(appModel.upsertProfileCalled)
    }

    func testUpdateAvatar() async throws {
        apiClient.performWithMultipartRequestRV = APIResponse(
            data: TestData.profileDTO,
            included: nil
        )
        appModel.upsertProfileRV = TestData.profileSubject
        _ = try await userProfileService.updateAvatar(userID: TestData.profileDTO.id, image: UIImage(systemName: "xmark")!)
        XCTAssertTrue(apiClient.performWithMultipartRequestCalled)
        XCTAssertEqual(apiClient.performWithMultipartRequestParams?.0, APIOperation.userProfileAvatarUpload)
        XCTAssertTrue(appModel.upsertProfileCalled)
    }
}
