import PrefabAppCoreInterface
import PrefabAppUI
import SwiftUI

/// A container view that requires login and onboarding before granting access to its content.
public struct AccessControlledView<UserSession, Content: View>: View {
    private enum AuthState {
        case initial
        case loggedIn
        case loggedOut
    }

    private let analytics: AnalyticsProtocol
    private let authClient: AuthClientProtocol
    private let userProfileInitializer: UserProfileInitializerProtocol
    private let userSessionInitializer: (UserProfile) async throws -> UserSession

    @State private var authState: AuthState = .initial

    private let content: (UserSession) -> Content

    /// Creates a new `AccessControlledView` instance.
    /// - Parameters:
    ///   - analytics: An `AnalyticsProtocol` instance.
    ///   - authClient: An `AuthClient` instance.
    ///   - userProfileInitializer: A `UserProfileInitializerProtocol` instance.
    ///   - userSessionInitializer: A closure that initializes a new user session with a user profile.
    ///   - content: A closure that returns the content view to display once access is granted.
    public init(
        analytics: AnalyticsProtocol,
        authClient: AuthClientProtocol,
        userProfileInitializer: UserProfileInitializerProtocol,
        userSessionInitializer: @escaping (UserProfile) async throws -> UserSession,
        @ViewBuilder _ content: @escaping (UserSession) -> Content
    ) {
        self.analytics = analytics
        self.authClient = authClient
        self.userProfileInitializer = userProfileInitializer
        self.userSessionInitializer = userSessionInitializer
        self.content = content
    }

    public var body: some View {
        Group {
            switch authState {
            case .initial:
                ProgressView()
                    .tint(AppColor.contentPrimary.color)
            case .loggedOut:
                LoginFlow()
                    .environmentObject(EnvironmentValueContainer(value: authClient))
            case .loggedIn:
                UserSessionRootView(
                    userProfileInitializer: userProfileInitializer,
                    userSessionInitializer: userSessionInitializer,
                    content: content
                )
            }
        }
        .environmentObject(EnvironmentValueContainer(value: analytics))
        .task {
            for await authEvent in authClient.eventStream {
                switch authEvent {
                case .loggedIn:
                    authState = .loggedIn
                case .loggedOut:
                    authState = .loggedOut
                }
            }
        }
    }
}
