import PrefabAppCoreInterface
import PhotosUI
import SwiftUI

/// Profile picture section in the edit profile view.
struct ProfileEditPictureSection: View {
    @EnvironmentObject private var analytics: EnvironmentValueContainer<AnalyticsProtocol>
    @EnvironmentObject private var userProfileService: EnvironmentValueContainer<UserProfileServiceProtocol>

    /// A user profile.
    let userProfile: UserProfile

    private enum SelectionState {
        case idle
        case loading(PhotosPickerItem)
        case loadingFailure(AlertError)
        case loaded(UIImage)
    }

    private enum ProfileImageSource {
        case data(Image)
        case url(URL?)
    }

    @State private var state: SelectionState = .idle

    private var photoSelection: Binding<PhotosPickerItem?> {
        Binding(
            get: {
                if case let .loading(photosPickerItem) = state {
                    return photosPickerItem
                } else {
                    return nil
                }
            },
            set: { photosPickerItem in
                if let photosPickerItem {
                    state = .loading(photosPickerItem)
                } else {
                    state = .idle
                }
            }
        )
    }

    var body: some View {
        switch state {
        case .idle:
            PhotosPicker(
                selection: photoSelection,
                matching: .images
            ) {
                content(imageSource: .url(userProfile.avatarUrl))
            }
        case let .loading(photosPickerItem):
            content(imageSource: .url(nil), showProgressView: true)
                .task {
                    do {
                        let image = try await photosPickerItem.loadMediaItem().value
                        try await userProfileService.value.updateAvatar(userID: userProfile.id, image: image)
                        state = .loaded(image)
                    } catch {
                        analytics.value.logError(error)
                        let alertError = AlertError(
                            wrappedError: error,
                            fallbackErrorDescription: String(localized: "Image Upload Failed", comment: "Error description")
                        )
                        state = .loadingFailure(alertError)
                    }
                }
        case let .loadingFailure(error):
            content(imageSource: .url(nil))
                .alert(
                    isPresented: .constant(true),
                    error: error,
                    actions: {
                        Button {
                            state = .idle
                        } label: {
                            Text("OK", comment: "Button title")
                        }
                    }
                )
        case let .loaded(image):
            PhotosPicker(
                selection: photoSelection,
                matching: .images
            ) {
                content(imageSource: .data(Image(uiImage: image)))
            }
        }
    }

    @ViewBuilder private func content(
        imageSource: ProfileImageSource,
        showProgressView: Bool = false
    ) -> some View {
        VStack(spacing: 16) {
            Group {
                switch imageSource {
                case let .data(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                case let .url(url):
                    CircleAsyncImage(imageURL: url)
                }
            }
            .frame(width: 120, height: 120)
            .overlay(
                Group {
                    if showProgressView {
                        ProgressView()
                            .tint(AppColor.contentPrimary.color)
                    }
                }
            )
            Text("Edit picture", comment: "Button title")
                .font(.footnote.weight(.semibold))
        }
        .padding(.vertical, 16)
    }
}
