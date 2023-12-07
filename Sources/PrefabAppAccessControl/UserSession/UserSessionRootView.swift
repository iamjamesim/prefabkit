import PrefabAppCoreInterface
import PrefabAppUI
import SwiftUI

/// The root view of an authenticated user session.
///
/// When this view first appears, it attempts to load the authenticated user's profile. If a profile is not found, the
/// new user profile creation flow is shown. If a profile is found, a new session is activated, and the main app
/// experience is shown.
struct UserSessionRootView<UserSession, Content: View>: View {
    private enum UserSessionState {
        case loading
        case loadingError
        case userProfileCreate
        case active(UserSession)
    }

    @EnvironmentObject private var analytics: EnvironmentValueContainer<AnalyticsProtocol>

    @State private var userSessionState: UserSessionState = .loading

    /// A `UserProfileInitializerProtocol` instance.
    let userProfileInitializer: UserProfileInitializerProtocol
    /// A closure that initializes a new user session with a user profile.
    let userSessionInitializer: (UserProfile) async throws -> UserSession
    let content: (UserSession) -> Content

    var body: some View {
        Group {
            switch userSessionState {
            case .loading:
                ProgressView()
                    .tint(AppColor.contentPrimary.color)
            case .loadingError:
                LoadingErrorView {
                    Task {
                        await load()
                    }
                }
            case .userProfileCreate:
                UserProfileCreateFlow(
                    userProfileInitializer: userProfileInitializer,
                    userSessionInitializer: userSessionInitializer
                ) { userSession in
                    userSessionState = .active(userSession)
                }
            case let .active(userProfile):
                content(userProfile)
            }
        }.task {
            await load()
        }
    }

    @MainActor
    private func load() async {
        userSessionState = .loading
        do {
            let userProfile = try await userProfileInitializer.currentUserProfile()
            let userSession = try await userSessionInitializer(userProfile)
            userSessionState = .active(userSession)
        } catch UserProfileServiceError.profileNotFound {
            userSessionState = .userProfileCreate
        } catch {
            analytics.value.logError(error)
            userSessionState = .loadingError
        }
    }
}
