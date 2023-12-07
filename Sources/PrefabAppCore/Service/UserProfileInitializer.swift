import Foundation
import PrefabAppCoreInterface

class UserProfileInitializer: UserProfileInitializerProtocol {
    private let apiClient: APIClientProtocol

    /// Creates a new `UserProfileInitializer` instance.
    /// - Parameters:
    ///   - apiClient: An API client to use to perform API operations.
    init(
        apiClient: APIClientProtocol
    ) {
        self.apiClient = apiClient
    }

    func currentUserProfile() async throws -> UserProfile {
        let response: APIResponse<UserProfileDTO?> = try await apiClient
            .perform(operation: APIOperation.currentUserProfile)
        if let dto = response.data {
            return UserProfile(dto: dto)
        } else {
            throw UserProfileServiceError.profileNotFound
        }
    }

    func createUserProfile(username: String, displayName: String) async throws -> UserProfile {
        struct UserProfileCreateParams: Encodable {
            let username: String
            let displayName: String
        }
        let response: APIResponse<UserProfileDTO> = try await apiClient
            .perform(
                operation: APIOperation.userProfileCreate,
                params: UserProfileCreateParams(username: username, displayName: displayName)
            )
        return UserProfile(dto: response.data)
    }
}
