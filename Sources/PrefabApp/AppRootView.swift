import PrefabAppAccessControl
import PrefabAppCoreInterface
import PrefabAppUI
import SwiftUI

/// The root view of a Prefab app.
public struct AppRootView: View {
    private let analytics: AnalyticsProtocol
    private let iconAssetBundle: Bundle
    private let authClient: AuthClientProtocol
    private let userProfileInitializer: UserProfileInitializerProtocol
    private let userSessionInitializer: (UserProfile) async throws -> (UserSession, UserSessionScopedServices)

    /// Creates a new `AppRootView` instance with the provided dependencies.
    /// - Parameters:
    ///   - analytics: An `AnalyticsProtocol` instance.
    ///   - iconAssetBundle: A bundle that contains icon assets.
    ///   - authClient: An `AuthClient` instance.
    ///   - userProfileInitializer: A `UserProfileInitializerProtocol` instance.
    ///   - userSessionInitializer: A closure that initializes a user session and session scoped services.
    public init(
        analytics: AnalyticsProtocol,
        iconAssetBundle: Bundle,
        authClient: AuthClientProtocol,
        userProfileInitializer: UserProfileInitializerProtocol,
        userSessionInitializer: @escaping (UserProfile) async throws -> (UserSession, UserSessionScopedServices)
    ) {
        self.analytics = analytics
        self.iconAssetBundle = iconAssetBundle
        self.authClient = authClient
        self.userProfileInitializer = userProfileInitializer
        self.userSessionInitializer = userSessionInitializer
    }

    public var body: some View {
        AccessControlledView(
            analytics: analytics,
            authClient: authClient,
            userProfileInitializer: userProfileInitializer,
            userSessionInitializer: userSessionInitializer
        ) { (userSession, services) in
            AppPagesView(
                analytics: analytics,
                appService: services.appService,
                iconAssetBundle: iconAssetBundle,
                userProfileService: services.userProfileService,
                userSession: userSession
            )
        }
    }
}
