import PrefabAppCoreInterface
import PrefabAppUI
import SwiftUI

/// The root view of an authenticated user session.
///
/// When this view first appears, it attempts to load the authenticated user's profile. If a profile is not found, the
/// new user profile creation flow is shown. If a profile is found, a new session is activated, and the main app
/// experience is shown.
struct UserSessionRootView<Content: View>: View {
    private enum UserSessionState {
        case loading
        case loadingError
        case userProfileCreate
        case active(UserSession)
    }

    @EnvironmentObject private var analytics: EnvironmentValueContainer<AnalyticsProtocol>
    @EnvironmentObject private var userProfileService: EnvironmentValueContainer<UserProfileServiceProtocol>

    @State private var userSessionState: UserSessionState = .loading

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
                UserProfileCreateFlow { newProfile in
                    userSessionState = .active(UserSession(userProfileSubject: newProfile))
                }
            case let .active(userSession):
                content(userSession)
            }
        }.task {
            await load()
        }
    }

    @MainActor
    private func load() async {
        userSessionState = .loading
        do {
            let userProfileSubject = try await userProfileService.value.currentUserProfile()
            userSessionState = .active(UserSession(userProfileSubject: userProfileSubject))
        } catch UserProfileServiceError.profileNotFound {
            userSessionState = .userProfileCreate
        } catch {
            analytics.value.logError(error)
            userSessionState = .loadingError
        }
    }
}
