import PrefabAppCoreInterface
import SwiftUI

/// A profile page header that shows user information.
struct ProfileHeaderView: View {
    @EnvironmentObject private var pageRouter: PageRouter
    @EnvironmentObject private var userSession: UserSession

    /// An `ObservableSubject` that contains a user profile.
    @StateObject var viewModel: ObservableSubject<UserProfile>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .bottom) {
                CircleAsyncImage(imageURL: viewModel.value.avatarUrl)
                    .frame(width: 120, height: 120)
                Spacer()
                if userSession.userProfileSubject.value.id == viewModel.value.id {
                    Button {
                        pageRouter.presentModalDestination(.profileEdit(userSession.userProfileSubject))
                    } label: {
                        Text("Edit Profile", comment: "Profile edit button title")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColor.buttonSecondaryForeground.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(AppColor.buttonSecondaryBackground.color)
                            )
                    }
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.value.displayName)
                    .font(.title.weight(.semibold))
                Text("@\(viewModel.value.username)")
                    .font(.body)
                    .foregroundColor(AppColor.contentPrimary.color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
