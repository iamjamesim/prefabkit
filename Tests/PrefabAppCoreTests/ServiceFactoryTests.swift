import XCTest
@testable import PrefabAppCore

final class ServiceFactoryTests: XCTestCase {
    private var apiClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
    }

    override func tearDown() {
        apiClient = nil
        super.tearDown()
    }

    func testThatServicesShareAppModel() async throws {
        let appService = ServiceFactory.appService(appID: "123", apiClient: apiClient)
        let userProfileService = ServiceFactory.userProfileService(apiClient: apiClient)

        apiClient.performRV = APIResponse(
            data: TestData.profileDTO as UserProfileDTO?,
            included: nil
        )
        let userProfile = try await userProfileService.currentUserProfile()

        apiClient.performRV = APIResponse(
            data: TestData.itemDTO,
            included: [
                AnyAppObjectDTO(dto: UserProfileDTO(
                    id: TestData.profileDTO.id,
                    username: TestData.profileDTO.username,
                    displayName: "New Displayname",
                    avatarUrl: nil,
                    bio: nil,
                    insertedAt: TestData.profileDTO.insertedAt
                ))
            ]
        )
        _ = try await appService.saveItem(itemID: TestData.itemDTO.id)

        XCTAssertEqual(userProfile.value.displayName, "New Displayname")
    }
}
