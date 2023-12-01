import PrefabAppAccessControl
import PrefabAppCoreInterface
import PrefabAppUI
import SwiftUI

/// The root view of a Prefab app.
public struct AppRootView: View {
    private let analytics: AnalyticsProtocol
    private let appService: AppServiceProtocol
    private let iconAssetBundle: Bundle
    private let authClient: AuthClientProtocol
    private let userProfileService: UserProfileServiceProtocol

    /// Creates a new `AppRootView` instance with the provided dependencies.
    /// - Parameters:
    ///   - analytics: An `AnalyticsProtocol` instance.
    ///   - appService: An `AppServiceProtocol` instance.
    ///   - iconAssetBundle: A bundle that contains icon assets.
    ///   - authClient: An `AuthClient` instance.
    ///   - userProfileService: A `UserProfileServiceProtocol` instance.
    public init(
        analytics: AnalyticsProtocol,
        appService: AppServiceProtocol,
        iconAssetBundle: Bundle,
        authClient: AuthClientProtocol,
        userProfileService: UserProfileServiceProtocol
    ) {
        self.analytics = analytics
        self.appService = appService
        self.iconAssetBundle = iconAssetBundle
        self.authClient = authClient
        self.userProfileService = userProfileService
    }

    public var body: some View {
        AccessControlledView(
            analytics: analytics,
            authClient: authClient,
            userProfileService: userProfileService
        ) { userSession in
            AppPagesView(
                analytics: analytics,
                appService: appService,
                iconAssetBundle: iconAssetBundle,
                userProfileService: userProfileService,
                userSession: userSession
            )
        }
    }
}
