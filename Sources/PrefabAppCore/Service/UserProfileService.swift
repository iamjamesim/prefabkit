import Foundation
import PrefabAppCoreInterface
import UIKit

class UserProfileService: UserProfileServiceProtocol {
    private let apiClient: APIClientProtocol
    private let appModel: AppModelProtocol

    /// Creates a new `UserProfileService` instance.
    /// - Parameters:
    ///   - apiClient: An API client to use to perform API operations.
    ///   - appModel: An app model to use to store and retrieve app objects.
    init(
        apiClient: APIClientProtocol,
        appModel: AppModelProtocol
    ) {
        self.apiClient = apiClient
        self.appModel = appModel
    }

    func userProfile(userID: String) async throws -> UserProfileSubject {
        struct Params: Encodable {
            let userID: String
        }
        if let existingProfile = try await appModel.userProfile(userID: userID) {
            return existingProfile
        } else {
            let response: APIResponse<UserProfileDTO> = try await apiClient
                .perform(
                    operation: APIOperation.userProfile,
                    params: Params(userID: userID)
                )
            return try appModel.upsertProfile(inResponse: response)
        }
    }

    func updateUsername(_ username: String) async throws {
        struct Params: Encodable {
            let username: String
        }
        let response: APIResponse<UserProfileDTO> = try await apiClient
            .perform(
                operation: APIOperation.userProfileUpdate,
                params: Params(username: username)
            )
        try appModel.upsertProfile(inResponse: response)
    }

    func updateDisplayName(_ displayName: String) async throws {
        struct Params: Encodable {
            let displayName: String
        }
        let response: APIResponse<UserProfileDTO> = try await apiClient
            .perform(
                operation: APIOperation.userProfileUpdate,
                params: Params(displayName: displayName)
            )
        try appModel.upsertProfile(inResponse: response)
    }

    func updateAvatar(userID: String, image: UIImage) async throws {
        let fileData = try image.downsizedIfNeeded(toWidth: 200).validJpegData(compressionQuality: 1)
        var multipartRequest = MultipartRequest()
        multipartRequest.addFile(
            MultipartRequest.File(
                partName: "avatar",
                fileName: userID,
                mimeType: .jpeg,
                fileData: fileData
            )
        )
        let response: APIResponse<UserProfileDTO> = try await apiClient
            .perform(
                operation: APIOperation.userProfileAvatarUpload,
                multipartRequest: multipartRequest
            )
        try appModel.upsertProfile(inResponse: response)
    }
}
