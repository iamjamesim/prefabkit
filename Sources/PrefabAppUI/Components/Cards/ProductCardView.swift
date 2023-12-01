import PrefabAppCoreInterface
import SwiftUI

struct ProductCardView: View {
    /// An item.
    let item: Item
    /// Icon buttons.
    let iconButtons: [ItemCardIconButton]
    /// Menu items.
    let menuItems: [ItemCardMenuItem]
    /// The card layout.
    let layout: ItemCardLayout
    /// A closure that downloads an image.
    let downloadImage: (String) async throws -> Image
    /// A closure that is called when the card is tapped.
    let onCardTap: () -> Void
    /// A closure that is called when the profile attribution is tapped.
    let onProfileAttributionTap: (UserProfileSubject) -> Void
    /// A closure that is called when an icon button is tapped.
    let onIconButtonTap: (ItemCardIconButton.Action, Item) -> Void
    /// A closure that is called when a menu item is tapped.
    let onMenuItemTap: (ItemCardMenuItem.Action, Item) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: layout.textVerticalSpacing) {
            Button {
                onCardTap()
            } label: {
                VStack(alignment: .leading, spacing: layout.textVerticalSpacing) {
                    media
                    metadata
                }
                .frame(width: layout.cardWidth, alignment: .leading)
            }
            .tint(AppColor.contentPrimary.color)
        }
    }

    @ViewBuilder private var media: some View {
        if let imagePath = item.imagePath {
            CustomAsyncImage(download: {
                try await downloadImage(imagePath)
            })
            .frame(width: layout.cardWidth, height: layout.cardWidth)
            .clipped()
            .cornerRadius(8)
            .overlay(mediaAccessoryView, alignment: .topTrailing)
        }
    }

    @ViewBuilder private var mediaAccessoryView: some View {
        if let actionButton = iconButtons.first {
            switch actionButton.action {
            case .like:
                IconToggleButton(
                    icon: Icon(name: actionButton.icon),
                    size: layout.actionButtonSize,
                    isActive: Binding<Bool>(get: {
                        item.isLiked
                    }, set: { _ in
                        onIconButtonTap(.like, item)
                    }),
                    inactiveColors: .init(fill: AppColor.black.color.opacity(0.5), outline: AppColor.white.color),
                    activeColors: .init(
                        fill: actionButton.activeColorOverride ?? AppColor.white.color,
                        outline: AppColor.white.color
                    )
                )
                .padding(8)
            case .save:
                IconToggleButton(
                    icon: Icon(name: actionButton.icon),
                    size: layout.actionButtonSize,
                    isActive: Binding<Bool>(get: {
                        item.isSaved
                    }, set: { _ in
                        onIconButtonTap(.save, item)
                    }),
                    inactiveColors: .init(fill: AppColor.black.color.opacity(0.5), outline: AppColor.white.color),
                    activeColors: .init(
                        fill: actionButton.activeColorOverride ?? AppColor.white.color,
                        outline: AppColor.white.color
                    )
                )
                .padding(8)
            case .unknown:
                EmptyView()
            }
        }
    }

    @ViewBuilder private var metadata: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                if let name = item.name {
                    Text(name)
                        .font(AppFont.font(withSize: layout.textSize, weight: .semibold))
                        .lineLimit(2)
                        .foregroundColor(AppColor.contentPrimary.color)
                        .multilineTextAlignment(.leading)
                    secondaryText
                        .foregroundStyle(AppColor.contentSecondary.color)
                } else {
                    secondaryText
                        .foregroundStyle(AppColor.contentPrimary.color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ItemCardMoreMenu(menuItems: menuItems, onMenuItemTap: { onMenuItemTap($0, item) })
        }
    }

    @ViewBuilder private var secondaryText: some View {
        if let description = item.description {
            Text(description)
                .font(AppFont.font(withSize: layout.textSize, weight: .regular))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        } else if let body = item.body {
            Text(body)
                .font(AppFont.font(withSize: layout.textSize, weight: .regular))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
}

struct ProductCardView_Previews: PreviewProvider {
    struct ImageLoadingError: Error {}

    struct PreviewContainer: View {
        let cardWidth: CGFloat

        var body: some View {
            ProductCardView(
                item: PreviewData.item,
                iconButtons: [.init(icon: "heart", action: .save)],
                menuItems: [],
                layout: .init(cardWidth: cardWidth),
                downloadImage: { _ in
                    let request = URLRequest(url: PreviewData.itemImageURL)
                    let (data, _) = try await URLSession.shared.data(for: request)
                    guard let uiImage = UIImage(data: data) else {
                        throw ImageLoadingError()
                    }
                    return Image(uiImage: uiImage)
                },
                onCardTap: {},
                onProfileAttributionTap: { _ in },
                onIconButtonTap: { _, _ in },
                onMenuItemTap: { _, _ in }
            )
            .padding(16)
        }
    }

    static var previews: some View {
        PreviewVariants {
            ScrollView {
                VStack {
                    PreviewContainer(cardWidth: 120)
                        .padding(16)
                    PreviewContainer(cardWidth: 160)
                        .padding(16)
                    PreviewContainer(cardWidth: 240)
                        .padding(16)
                    PreviewContainer(cardWidth: 320)
                        .padding(16)
                }
            }
        }
    }
}
