import PrefabAppCoreInterface
import SwiftUI

/// A user profile view.
struct ProfileView: View {
    @EnvironmentObject private var pageContext: EnvironmentValueContainer<PageContext>
    @EnvironmentObject private var userProfileService: EnvironmentValueContainer<UserProfileServiceProtocol>

    /// Subpages to show in the content section of the page.
    let subpages: [SubpageSpec]

    var body: some View {
        DataLoadingView(
            load: { () async throws -> UserProfileSubject in
                guard let profileID = pageContext.value.objectID else {
                    throw ProfileViewError.missingProfileID
                }
                return try await userProfileService.value.userProfile(userID: profileID)
            }
        ) { userProfileSubject in
            SubpagesView(
                header: {
                    ProfileHeaderView(viewModel: ObservableSubject(subject: userProfileSubject))
                        .padding(24)
                },
                subpages: subpages
            )
            .frame(maxHeight: .infinity)
        }
    }
}

private enum ProfileViewError: Error {
    case missingProfileID
}
