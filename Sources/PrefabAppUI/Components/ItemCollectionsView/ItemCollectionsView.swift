import PrefabAppCoreInterface
import SwiftUI

/// A view that displays item collections.
struct ItemCollectionsView: View {
    /// An item collections view model.
    @StateObject var viewModel: ItemCollectionsViewModel
    /// A message shown when the page is empty.
    let emptyStateMessage: String
    /// An item collection spec.
    let collectionSpec: ItemCollectionSpec?
    /// An item card spec.
    let cardSpec: ItemCardSpec?
    /// A closure that is called when an add item button is tapped.
    ///
    /// If not nil, an add item button is shown for each item collection, and the collection ID is passed to the
    /// closure when the button is tapped.
    let collectionAddItemAction: ((String) -> Void)?
    /// The available width within the parent view.
    let availableWidth: CGFloat

    var body: some View {
        if viewModel.isEmpty {
            Text(emptyStateMessage)
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.collections) { collection in
                    ItemCollectionView(
                        viewModel: ObservableSubject<ItemCollection>(subject: collection),
                        layout: collection.value.layout,
                        collectionSpec: collectionSpec,
                        cardSpec: cardSpec,
                        addItemAction: collectionAddItemAction,
                        availableWidth: availableWidth
                    )
                }
            }
            .padding(.vertical, 24)
        }
    }
}
