import Foundation
import PrefabAppCoreInterface

public class ServiceFactory {
    private static let appModel = AppModel(objectStore: AppObjectStore())

    public static func appService(appID: String, apiClient: APIClientProtocol) -> AppServiceProtocol {
        AppService(appID: appID, apiClient: apiClient, appModel: appModel)
    }

    public static func userProfileService(apiClient: APIClientProtocol) -> UserProfileServiceProtocol {
        UserProfileService(apiClient: apiClient, appModel: appModel)
    }
}
