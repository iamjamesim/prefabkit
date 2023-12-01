import PrefabAppCoreInterface
import SwiftUI

/// An image loaded from a closure that downloads an image.
public struct CustomAsyncImage: View {
    @EnvironmentObject private var analytics: EnvironmentValueContainer<AnalyticsProtocol>
    @EnvironmentObject private var iconAssetBundle: EnvironmentValueContainer<Bundle>

    /// A closure that downloads an image.
    public let download: () async throws -> Image?

    @State private var hasLoaded: Bool = false
    @State private var state: LoadingState<Image?> = .loading

    public init(download: @escaping () async throws -> Image?) {
        self.download = download
    }

    public var body: some View {
        Group {
            switch state {
            case .loading:
                AppColor.imagePlaceholder.color
            case .error:
                AppColor.imagePlaceholder.color
                    .overlay(
                        Icon.warning.outlineImage(bundle: iconAssetBundle.value)
                            .foregroundColor(AppColor.contentPrimary.color)
                    )
            case let .loaded(image):
                if let image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    AppColor.imagePlaceholder.color
                }
            }
        }
        .task {
            guard !hasLoaded || state.isError else {
                return
            }
            hasLoaded = true

            state = .loading
            do {
                state = .loaded(try await download())
            } catch {
                analytics.value.logError(error)
                state = .error
            }
        }
    }
}

struct CustomAsyncImage_Previews: PreviewProvider {
    struct ImageLoadingError: Error {}

    static var previews: some View {
        PreviewVariants {
            HStack {
                LabeledPreview(label: "Loading") {
                    CustomAsyncImage(download: {
                        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Image, Error>) in
                            // noop
                        }
                    })
                    .frame(width: 64, height: 64)
                    .padding(8)
                }
                LabeledPreview(label: "Error") {
                    CustomAsyncImage(download: {
                        throw ImageLoadingError()
                    })
                    .frame(width: 64, height: 64)
                    .padding(8)
                }
                LabeledPreview(label: "Loaded") {
                    CustomAsyncImage(download: {
                        let request = URLRequest(url: PreviewData.profileImageURL)
                        let (data, _) = try await URLSession.shared.data(for: request)
                        guard let uiImage = UIImage(data: data) else {
                            throw ImageLoadingError()
                        }
                        return Image(uiImage: uiImage)
                    })
                    .frame(width: 64, height: 64)
                    .clipped()
                    .padding(8)
                }
            }
        }
    }
}
