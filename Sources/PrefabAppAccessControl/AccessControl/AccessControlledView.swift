import PrefabAppCoreInterface
import PrefabAppUI
import SwiftUI

/// A container view that requires login and onboarding before granting access to its content.
public struct AccessControlledView<Content: View>: View {
    private enum AuthState {
        case initial
        case loggedIn
        case loggedOut
    }

    private let analytics: AnalyticsProtocol
    private let authClient: AuthClientProtocol
    private let userProfileService: UserProfileServiceProtocol

    @State private var authState: AuthState = .initial

    private let content: (UserSession) -> Content

    /// Creates a new `AccessControlledView` instance.
    /// - Parameters:
    ///   - analytics: An `AnalyticsProtocol` instance.
    ///   - authClient: An `AuthClient` instance.
    ///   - userProfileService: A `UserProfileServiceProtocol` instance.
    ///   - content: A closure that returns the content view to display once access is granted.
    public init(
        analytics: AnalyticsProtocol,
        authClient: AuthClientProtocol,
        userProfileService: UserProfileServiceProtocol,
        @ViewBuilder _ content: @escaping (UserSession) -> Content
    ) {
        self.analytics = analytics
        self.authClient = authClient
        self.userProfileService = userProfileService
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
                UserSessionRootView(content: content)
                    .environmentObject(EnvironmentValueContainer(value: analytics))
                    .environmentObject(EnvironmentValueContainer(value: userProfileService))
            }
        }.task {
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
