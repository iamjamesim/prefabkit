import PrefabAppCoreInterface
import SwiftUI

/// A view that displays an item collection.
struct ItemCollectionView: View {
    @EnvironmentObject private var analytics: EnvironmentValueContainer<AnalyticsProtocol>
    @EnvironmentObject private var appService: EnvironmentValueContainer<AppServiceProtocol>
    @EnvironmentObject private var iconAssetBundle: EnvironmentValueContainer<Bundle>
    @EnvironmentObject private var pageRouter: PageRouter
    @EnvironmentObject private var userSession: UserSession

    /// An item collection view model.
    @StateObject var viewModel: ObservableSubject<ItemCollection>
    /// An item collection layout.
    let layout: ItemCollection.Layout
    /// An item collection spec.
    let collectionSpec: ItemCollectionSpec?
    /// An item card spec.
    let cardSpec: ItemCardSpec?
    /// A closure that is called when an add item button is tapped.
    ///
    /// If not nil, an add item button is shown for each item collection, and the collection ID is passed to the
    /// closure when the button is tapped.
    let addItemAction: ((String) -> Void)?
    /// The available width within the parent view.
    let availableWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            collectionHeader
            switch layout {
            case .verticalList:
                verticalList
            case .horizontalList:
                horizontalList
            case .unknown:
                verticalList
            }
        }
    }

    private var cardWidth: CGFloat {
        switch layout {
        case .verticalList:
            return availableWidth - 2 * layout.horizontalPadding
        case .horizontalList:
            let visibleItemsCount: CGFloat = 2
            let offScreenItemPeekWidth: CGFloat = 32
            let occupiedWidth = layout.horizontalPadding + visibleItemsCount * layout.itemSpacing + offScreenItemPeekWidth
            return (availableWidth - occupiedWidth) / visibleItemsCount
        case .unknown:
            return availableWidth - 2 * layout.horizontalPadding
        }
    }

    @ViewBuilder var collectionHeader: some View {
        if viewModel.value.name != nil || collectionSpec?.menuItems != nil {
            HStack(spacing: 4) {
                if let name = viewModel.value.name {
                    Text(name)
                        .font(.title.weight(.semibold))
                        .lineLimit(1)
                        .foregroundColor(AppColor.contentPrimary.color)
                }
                Spacer()
                if let menuItems = collectionSpec?.menuItems {
                    Menu {
                        ForEach(menuItems, id: \.action) { menuItem in
                            switch menuItem.action {
                            case .delete:
                                Button(role: .destructive) {
                                    onCollectionMenuItemTap(menuItem.action)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            case .unknown:
                                EmptyView()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .tint(AppColor.contentPrimary.color)
            .padding(.horizontal, layout.horizontalPadding)
        }
    }

    @ViewBuilder var verticalList: some View {
        LazyVStack(spacing: layout.itemSpacing) {
            itemCards
        }
        .padding(.horizontal, layout.horizontalPadding)
    }

    @ViewBuilder var horizontalList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: layout.itemSpacing) {
                itemCards
            }
            .padding(.horizontal, layout.horizontalPadding)
        }
    }

    @ViewBuilder var itemCards: some View {
        ForEach(viewModel.value.items) { itemSubject in
            ItemCardView(
                itemViewModel: .init(subject: itemSubject),
                iconButtons: cardSpec?.iconButtons ?? [],
                menuItems: filteredMenuItems(cardSpec: cardSpec, item: itemSubject.value),
                cardWidth: cardWidth,
                downloadImage: appService.value.downloadImage,
                onCardTap: {
                    switch itemSubject.value.itemType {
                    case .socialPost:
                        // noop
                        return
                    case .product:
                        pageRouter.presentModalDestination(.itemDetails(itemSubject))
                    case .unknown:
                        pageRouter.presentError(AlertError(wrappedError: ItemCollectionsActionError.unknownCardAction))
                    }
                },
                onProfileAttributionTap: { userProfileSubject in
                    pageRouter.pushDestination(
                        PageRouter.PushDestination(
                            destinationType: .userProfile,
                            pageContext: PageContext(pageID: nil, objectID: userProfileSubject.id)
                        )
                    )
                },
                onIconButtonTap: onIconButtonTap,
                onMenuItemTap: onCardMenuItemTap
            )
        }
        if let addItemAction {
            Button {
                addItemAction(viewModel.value.id)
            } label: {
                Icon.add.outlineImage(bundle: iconAssetBundle.value)
                    .resizable()
                    .frame(width: cardWidth / 2, height: cardWidth / 2)
                    .foregroundColor(AppColor.buttonSecondaryForeground.color)
                    .frame(width: cardWidth, height: cardWidth)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColor.buttonSecondaryBackground.color)
                    )
            }
        }
    }

    private func filteredMenuItems(cardSpec: ItemCardSpec?, item: Item) -> [ItemCardMenuItem] {
        cardSpec?.menuItems?.filter {
            $0.visibilityRule == .always ||
            ($0.visibilityRule == .own && item.creator?.id == userSession.userID)
        } ?? []
    }

    private func onIconButtonTap(_ action: ItemCardIconButton.Action, item: Item) {
        switch action {
        case .like:
            Task {
                do {
                    if item.isLiked {
                        try await appService.value.unlikeItem(itemID: item.id)
                    } else {
                        try await appService.value.likeItem(itemID: item.id)
                    }
                } catch {
                    analytics.value.logError(error)
                }
            }
        case .save:
            Task {
                do {
                    if item.isSaved {
                        try await appService.value.unsaveItem(itemID: item.id)
                    } else {
                        try await appService.value.saveItem(itemID: item.id)
                    }
                } catch {
                    analytics.value.logError(error)
                }
            }
        case .unknown:
            pageRouter.presentError(AlertError(wrappedError: ItemCollectionsActionError.unknownCardAction))
            return
        }
    }

    private func onCollectionMenuItemTap(_ action: ItemCollectionMenuItem.Action) {
        switch action {
        case .delete:
            Task {
                do {
                    try await appService.value.deleteItemCollection(collectionID: viewModel.value.id)
                } catch {
                    analytics.value.logError(error)
                    pageRouter.presentError(AlertError(wrappedError: error))
                }
            }
        case .unknown:
            pageRouter.presentError(AlertError(wrappedError: ItemCollectionsActionError.unknownCardAction))
            return
        }
    }

    private func onCardMenuItemTap(_ action: ItemCardMenuItem.Action, item: Item) {
        switch action {
        case .delete:
            Task {
                do {
                    try await appService.value.deleteItem(itemID: item.id)
                } catch {
                    analytics.value.logError(error)
                    pageRouter.presentError(AlertError(wrappedError: error))
                }
            }
        case .unknown:
            pageRouter.presentError(AlertError(wrappedError: ItemCollectionsActionError.unknownCardAction))
            return
        }
    }
}

extension ItemCollection.Layout {
    /// The horizontal padding around a collection.
    var horizontalPadding: CGFloat {
        switch self {
        case .verticalList:
            return 24
        case .horizontalList:
            return 16
        case .unknown:
            return 24
        }
    }

    /// The spacing between item cards within a collection.
    var itemSpacing: CGFloat {
        switch self {
        case .verticalList:
            return 24
        case .horizontalList:
            return 16
        case .unknown:
            return 24
        }
    }
}
