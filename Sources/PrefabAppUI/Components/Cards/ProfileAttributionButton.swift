import PrefabAppCoreInterface
import SwiftUI

/// A button that shows a profile attribution row with image and username.
struct ProfileAttributionButton: View {
    /// A profile view model.
    @ObservedObject var profileViewModel: ObservableSubject<UserProfile>
    /// A button action.
    let action: () -> Void
    /// The text size for the username.
    let textSize: CGFloat
    var imageSize: CGFloat {
        (textSize * 2).roundToMultiple(of: 4)
    }

    var body: some View {
        Button(action: action) {
            CircleAsyncImage(imageURL: profileViewModel.value.avatarUrl)
                .frame(width: imageSize, height: imageSize)
            Text(profileViewModel.value.username)
                .font(AppFont.font(withSize: textSize, weight: .medium))
                .lineLimit(1)
        }
        .tint(AppColor.contentPrimary.color)
    }
}

struct ProfileAttributionButton_Previews: PreviewProvider {
    static var previews: some View {
        PreviewVariants {
            let profileViewModel = ObservableSubject<UserProfile>(subject: .init(PreviewData.userProfile))
            ProfileAttributionButton(profileViewModel: profileViewModel, action: {}, textSize: 17)
                .padding(16)
        }
    }
}
