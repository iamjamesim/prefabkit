import PrefabAppCoreInterface
import SwiftUI

struct SubpageView: View {
    struct ScrollToRequest: Equatable {
        enum Value {
            case top
            case contentToTop
        }
        let value: Value
        let id: Int
    }

    @EnvironmentObject private var analytics: EnvironmentValueContainer<AnalyticsProtocol>
    @EnvironmentObject private var appService: EnvironmentValueContainer<AppServiceProtocol>
    @EnvironmentObject private var pageContext: EnvironmentValueContainer<PageContext>
    @EnvironmentObject private var pageRouter: PageRouter

    let subpageSpec: SubpageSpec
    let headerHeight: CGFloat
    let onContentFrameChange: (CGRect, CGFloat) -> Void
    let scrollToRequest: ScrollToRequest?

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack {
                        Spacer()
                            .frame(height: headerHeight)
                            .id("SubpageView.spacer")
                        subpageContentView(subpageSpec: subpageSpec, availableWidth: geometry.size.width)
                            .frame(minHeight: geometry.size.height, alignment: .top)
                            .id("SubpageView.content")
                    }
                    .background(
                        ScrollContentFrameObserver(
                            coordinateSpace: .named("SubpageView"),
                            onContentFrameChange: { frame in
                                onContentFrameChange(frame, geometry.size.height)
                            }
                        )
                        .frame(maxHeight: .infinity)
                    )
                }
                .onChange(of: scrollToRequest) { scrollToRequest in
                    if let scrollToRequest {
                        switch scrollToRequest.value {
                        case .top:
                            scrollViewProxy.scrollTo("SubpageView.spacer", anchor: .top)
                        case .contentToTop:
                            scrollViewProxy.scrollTo("SubpageView.content", anchor: .top)
                        }
                    }
                }
            }
        }
        .coordinateSpace(name: "SubpageView")
        .overlay(
            Group {
                if let itemFormSpec = subpageSpec.itemFormSpec,
                   let floatingActionButton = subpageSpec.floatingActionButton {
                    switch floatingActionButton.action {
                    case .addItem:
                        FloatingActionButton(icon: Icon(name: floatingActionButton.icon)) {
                            presentItemForm(itemFormSpec: itemFormSpec, collectionID: nil)
                        }
                    case .addCollection:
                        FloatingActionButton(icon: Icon(name: floatingActionButton.icon)) {
                            pageRouter.presentModalDestination(.collectionCreate)
                        }
                    case .unknown:
                        EmptyView()
                    }
                }
            },
            alignment: .bottomTrailing
        )
    }

    @ViewBuilder private func subpageContentView(subpageSpec: SubpageSpec, availableWidth: CGFloat) -> some View {
        if case .unknown = subpageSpec.contentQuery {
            UnknownPageTypeView()
        } else {
            DataLoadingView(
                load: { () async throws -> PageContentSubject in
                    return try await appService.value.pageContent(
                        query: subpageSpec.contentQuery,
                        pageContext: pageContext.value
                    )
                }
            ) { pageContentSubject in
                ItemCollectionsView(
                    viewModel: ItemCollectionsViewModel(
                        pageContentSubject: pageContentSubject,
                        emptyStateCondition: subpageSpec.contentQuery.emptyStateCondition
                    ),
                    emptyStateMessage: subpageSpec.emptyStateMessage,
                    collectionSpec: subpageSpec.itemCollectionSpec,
                    cardSpec: subpageSpec.itemCardSpec,
                    collectionAddItemAction: collectionAddItemAction,
                    availableWidth: availableWidth
                )
            }
        }
    }

    private var collectionAddItemAction: ((String) -> Void)? {
        if let itemFormSpec = subpageSpec.itemFormSpec,
           let itemCollectionSpec = subpageSpec.itemCollectionSpec,
            itemCollectionSpec.newItemButtonEnabled {
            return { collectionID in
                presentItemForm(
                    itemFormSpec: itemFormSpec,
                    collectionID: collectionID
                )
            }
        } else {
            return nil
        }
    }

    private func presentItemForm(itemFormSpec: ItemFormSpec, collectionID: String?) {
        do {
            let fieldViewModels: [ItemFormFieldViewModel] = try itemFormSpec.fields.map { field in
                switch field.contentType {
                case .text, .url:
                    return ItemFormTextFieldViewModel(field: field)
                case .image:
                    return ItemFormImagePickerViewModel(field: field, analytics: analytics.value)
                case .unknown:
                    throw ItemCollectionsActionError.unknownFormFieldType
                }
            }
            let viewModel = ItemFormViewModel(
                itemType: itemFormSpec.itemType,
                formTitle: itemFormSpec.title,
                fieldViewModels: fieldViewModels,
                collectionID: collectionID,
                appService: appService.value
            )
            pageRouter.presentModalDestination(.itemCreate(viewModel))
        } catch {
            analytics.value.logError(error)
            pageRouter.presentError(AlertError(wrappedError: error))
        }
    }
}

extension PageContentQuery {
    var emptyStateCondition: ItemCollectionsViewModel.EmptyStateCondition {
        if case .collections = self {
            return .collectionsArrayEmpty
        } else {
            return .allCollectionsEmpty
        }
    }
}
