import PhotosUI
import SwiftUI

/// An image picker that allows the user to attach an image to an item.
struct ItemFormImagePicker: View {
    @EnvironmentObject private var iconAssetBundle: EnvironmentValueContainer<Bundle>

    /// An `ItemFormImagePickerViewModel`.
    @StateObject var viewModel: ItemFormImagePickerViewModel

    var body: some View {
        if let imageLoader = viewModel.selectedImageLoader {
            ItemFormImageAttachment(
                imageLoader: imageLoader,
                remove: { viewModel.selectedPhotosPickerItem = nil },
                onImageLoad: {
                    viewModel.delegate?.onInputStateChange()
                }
            )
        } else {
            PhotosPicker(
                selection: $viewModel.selectedPhotosPickerItem,
                matching: .images
            ) {
                Icon.image.outlineImage(bundle: iconAssetBundle.value)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(AppColor.contentPrimary.color)
                    .padding(12)
            }
            .padding(-12)
        }
    }
}
