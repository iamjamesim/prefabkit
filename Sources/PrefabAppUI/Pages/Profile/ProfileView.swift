import PrefabAppCoreInterface
import SwiftUI

/// A user profile view.
struct ProfileView: View {
    /// A `UserProfileSubject` that contains a user profile.
    let userProfileSubject: UserProfileSubject
    /// Subpages to show in the content section of the page.
    let subpages: [SubpageSpec]

    var body: some View {
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
