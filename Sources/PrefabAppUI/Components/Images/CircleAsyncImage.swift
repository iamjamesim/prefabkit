import SwiftUI

/// An circle-shaped image loaded from a URL.
struct CircleAsyncImage: View {
    /// An image URL.
    let imageURL: URL?

    var body: some View {
        AsyncImage(
            url: imageURL,
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            },
            placeholder: {
                AppColor.imagePlaceholder.color
            }
        )
        .clipShape(Circle())
    }
}

struct CircleAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        PreviewVariants {
            HStack {
                LabeledPreview(label: "Placeholder") {
                    CircleAsyncImage(imageURL: nil)
                        .frame(width: 64, height: 64)
                        .padding(8)
                }
                LabeledPreview(label: "Content") {
                    CircleAsyncImage(imageURL: PreviewData.profileImageURL)
                        .frame(width: 64, height: 64)
                        .padding(8)
                }
            }
        }
    }
}
