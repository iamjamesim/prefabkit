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
        let (userSession, services) = try await PrefabAppCoreFactory.sessionScopedServices(
            appID: TestData.profileDTO.id,
            currentUserProfile: TestData.profileSubject.value,
            apiClient: apiClient
        )

        apiClient.performRV = APIResponse(
            data: UserProfileDTO(
                id: TestData.profileDTO.id,
                username: TestData.profileDTO.username,
                displayName: "New Name 1",
                avatarUrl: nil,
                bio: nil,
                insertedAt: Date()
            ),
            included: nil
        )
        _ = try await services.userProfileService.updateDisplayName("New Name 1")
        XCTAssertEqual(userSession.userProfileSubject.value.displayName, "New Name 1")

        apiClient.performRV = APIResponse(
            data: TestData.itemDTO,
            included: [
                AnyAppObjectDTO(dto: UserProfileDTO(
                    id: TestData.profileDTO.id,
                    username: TestData.profileDTO.username,
                    displayName: "New Name 2",
                    avatarUrl: nil,
                    bio: nil,
                    insertedAt: TestData.profileDTO.insertedAt
                ))
            ]
        )
        _ = try await services.appService.saveItem(itemID: TestData.itemDTO.id)
        XCTAssertEqual(userSession.userProfileSubject.value.displayName, "New Name 2")
    }
}
