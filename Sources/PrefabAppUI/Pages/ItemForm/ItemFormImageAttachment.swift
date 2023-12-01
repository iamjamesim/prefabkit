import SwiftUI

/// A view that represents an item form image attachment.
struct ItemFormImageAttachment: View {
    @EnvironmentObject private var iconAssetBundle: EnvironmentValueContainer<Bundle>

    /// An image loader for the selected `PhotosPickerItem`.
    @StateObject var imageLoader: PhotosPickerItemLoader
    /// A closure that removes the image attachment.
    let remove: () -> Void
    /// A closure that is called when the image is loaded.
    let onImageLoad: () -> Void

    var body: some View {
        Group {
            switch imageLoader.loadingState {
            case .loading:
                AppColor.imagePlaceholder.color
            case .error:
                AppColor.imagePlaceholder.color
                    .overlay(
                        Icon.warning.outlineImage(bundle: iconAssetBundle.value)
                            .foregroundColor(AppColor.contentPrimary.color)
                    )
            case let .loaded(image):
                Image(uiImage: image)
                    .resizable()
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .cornerRadius(12)
        .overlay(
            Button(action: remove) {
                Image(systemName: "xmark")
                    .font(.system(size: 14).weight(.medium))
                    .foregroundStyle(AppColor.white.color)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(AppColor.black.color.opacity(0.6)))
            }.padding(12),
            alignment: .topTrailing
        )
        .onChange(of: imageLoader.loadedImage) { _ in
            onImageLoad()
        }
    }
}
