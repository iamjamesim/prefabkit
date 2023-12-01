import PrefabAppCoreInterface
import SwiftUI

/// An item card component.
struct ItemCardView: View {
    /// An item view model.
    @StateObject var itemViewModel: ObservableSubject<Item>
    private var item: Item {
        itemViewModel.value
    }
    /// Icon buttons.
    let iconButtons: [ItemCardIconButton]
    /// Menu items.
    let menuItems: [ItemCardMenuItem]
    /// The card width.
    let cardWidth: CGFloat
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

    private var layout: ItemCardLayout {
        ItemCardLayout(cardWidth: cardWidth)
    }

    var body: some View {
        switch item.itemType {
        case .socialPost:
            SocialPostView(
                item: item,
                iconButtons: iconButtons,
                menuItems: menuItems,
                layout: layout,
                downloadImage: downloadImage,
                onCardTap: onCardTap,
                onProfileAttributionTap: onProfileAttributionTap,
                onIconButtonTap: onIconButtonTap,
                onMenuItemTap: onMenuItemTap
            )
        case .product:
            ProductCardView(
                item: item,
                iconButtons: iconButtons,
                menuItems: menuItems,
                layout: layout,
                downloadImage: downloadImage,
                onCardTap: onCardTap,
                onProfileAttributionTap: onProfileAttributionTap,
                onIconButtonTap: onIconButtonTap,
                onMenuItemTap: onMenuItemTap
            )
        case .unknown:
            UnknownItemTypeView(layout: ItemCardLayout(cardWidth: cardWidth))
        }
    }
}
