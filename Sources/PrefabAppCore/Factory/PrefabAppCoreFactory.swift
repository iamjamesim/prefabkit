import Foundation
import PrefabAppCoreInterface

public class PrefabAppCoreFactory {
    public static func userProfileInitializer(apiClient: APIClientProtocol) -> UserProfileInitializerProtocol {
        UserProfileInitializer(apiClient: apiClient)
    }

    public static func sessionScopedServices(
        appID: String,
        currentUserProfile: UserProfile,
        apiClient: APIClientProtocol
    ) async throws -> (UserSession, UserSessionScopedServices) {
        let appModel = AppModel(objectStore: AppObjectStore(), currentUserID: currentUserProfile.id)
        let userProfileSubject = try await appModel.insertProfile(userProfile: currentUserProfile)
        let userSession = UserSession(userProfileSubject: userProfileSubject)
        let appService = AppService(appID: appID, apiClient: apiClient, appModel: appModel)
        let userProfileService = UserProfileService(apiClient: apiClient, appModel: appModel)
        return (userSession, UserSessionScopedServices(appService: appService, userProfileService: userProfileService))
    }
}
