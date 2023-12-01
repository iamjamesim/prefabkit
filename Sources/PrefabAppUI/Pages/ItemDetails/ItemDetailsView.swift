import PrefabAppCoreInterface
import SwiftUI

/// An item details view.
struct ItemDetailsView: View {
    private static let coordinateSpaceName = "ItemDetailsView"
    @Environment(\.dismiss) private var dismiss

    /// An `ObservableSubject` that contains an item.
    @StateObject var itemViewModel: ObservableSubject<Item>
    /// A closure that downloads an image.
    let imageDownload: (String) async throws -> Image

    @State private var navigationBarOpacity: CGFloat = 0

    var body: some View {
        if itemViewModel.value.imagePath != nil {
            contentWithAutoFadeNavBar
        } else {
            contentWithSystemNavBar
        }
    }

    @ViewBuilder private var contentWithAutoFadeNavBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ScrollView {
                        ZStack {
                            ItemDetailsContentView(
                                item: itemViewModel.value,
                                imageDownload: imageDownload,
                                imageSize: CGSize(width: geometry.size.width, height: geometry.size.width)
                            )
                            ScrollContentFrameObserver(
                                coordinateSpace: .named(Self.coordinateSpaceName),
                                onContentFrameChange: { frame in
                                    let yOffset = -frame.origin.y
                                    let imageHeight = geometry.size.width
                                    let navBarAndStatusBarHeight = ItemDetailsNavigationBar.height + geometry.safeAreaInsets.top
                                    let fullyTransparentYOffset = imageHeight / 2
                                    let fullyOpaqueYOffset = imageHeight - navBarAndStatusBarHeight
                                    let clampedYOffset = max(fullyTransparentYOffset, min(yOffset, fullyOpaqueYOffset))
                                    navigationBarOpacity = (clampedYOffset - fullyTransparentYOffset) / (fullyOpaqueYOffset - fullyTransparentYOffset)
                                }
                            )
                        }
                    }
                    .coordinateSpace(name: Self.coordinateSpaceName)
                    if let url = itemViewModel.value.url {
                        ItemDetailsBottomBar(url: url)
                    }
                }
                .edgesIgnoringSafeArea(.top)
                ItemDetailsNavigationBar(opacity: navigationBarOpacity)
            }
        }
    }

    @ViewBuilder private var contentWithSystemNavBar: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ScrollView {
                        ItemDetailsContentView(
                            item: itemViewModel.value,
                            imageDownload: imageDownload,
                            imageSize: CGSize(width: geometry.size.width, height: geometry.size.width)
                        )
                    }
                    if let url = itemViewModel.value.url {
                        ItemDetailsBottomBar(url: url)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        ToolbarSystemIcon(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}

private struct ItemDetailsContentView: View {
    let item: Item
    let imageDownload: (String) async throws -> Image
    let imageSize: CGSize

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imagePath = item.imagePath {
                CustomAsyncImage(download: {
                    try await imageDownload(imagePath)
                })
                .frame(width: imageSize.width, height: imageSize.height)
                .clipped()
            }
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    if let name = item.name {
                        Text(name)
                            .font(.title.weight(.semibold))
                            .multilineTextAlignment(.leading)
                    }
                    if let description = item.description {
                        Text(description)
                            .font(.title3)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(AppColor.contentSecondary.color)
                    }
                }
                if let body = item.body {
                    Text(body)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
            }
            .foregroundColor(AppColor.contentPrimary.color)
            .padding(16)
        }
    }
}

private struct NavigationBarOpacityModifier: ViewModifier {
    @Binding var navigationBarOpacity: CGFloat
    let imageHeight: CGFloat
    let navBarAndStatusBarHeight: CGFloat
    let coordinateSpace: CoordinateSpace

    func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollContentOriginPreferenceKey.self,
                    value: geometry.frame(in: coordinateSpace).origin
                )
            })
            .onPreferenceChange(ScrollContentOriginPreferenceKey.self) { contentOrigin in
                let yOffset = -contentOrigin.y
                let fullyTransparentYOffset = imageHeight / 2
                let fullyOpaqueYOffset = imageHeight - navBarAndStatusBarHeight
                let clampedYOffset = max(fullyTransparentYOffset, min(yOffset, fullyOpaqueYOffset))
                navigationBarOpacity = (clampedYOffset - fullyTransparentYOffset) / (fullyOpaqueYOffset - fullyTransparentYOffset)
            }
    }
}

private struct ScrollContentOriginPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint { .zero }
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}
