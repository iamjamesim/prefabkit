import PrefabAppCoreInterface
import SwiftUI

/// A standard tab root view that contains a page stack.
struct TabRootView: View {
    @EnvironmentObject private var appService: EnvironmentValueContainer<AppServiceProtocol>
    @EnvironmentObject private var iconAssetBundle: EnvironmentValueContainer<Bundle>
    @EnvironmentObject private var userSession: UserSession

    /// A page spec for the root page of the tab.
    let pageSpec: PageSpec
    /// Page specs for destination pages.
    let destinationPageSpecs: [DestinationPageSpec]
    /// A Boolean value that indicates whether the tab is currently selected.
    let isSelected: Bool

    private var tabIcon: Image {
        let icon = Icon(name: pageSpec.icon)
        if isSelected {
            return icon.fillImage(bundle: iconAssetBundle.value)
        } else {
            return icon.outlineImage(bundle: iconAssetBundle.value)
        }
    }

    @StateObject private var pageRouter = PageRouter()

    var body: some View {
        NavigationStack(path: $pageRouter.navigationStack) {
            PageView(
                pageType: pageSpec.pageType,
                pageContext: PageContext(pageID: pageSpec.id, objectID: pageSpec.objectId),
                subpages: pageSpec.subpages
            )
            .environmentObject(pageRouter)
            .navigationTitle(pageSpec.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: PageRouter.PushDestination.self) { destination in
                PageView(
                    pageType: destination.destinationType.pageType,
                    pageContext: destination.pageContext,
                    subpages: destinationPageSpecs.first {
                        $0.destinationType == destination.destinationType
                    }?.subpages ?? []
                )
            }
        }
        .fullScreenCover(item: $pageRouter.presentedModal) { presentedModal in
            modalView(for: presentedModal)
        }
        .alert(
            isPresented: .constant(pageRouter.presentedError != nil),
            error: pageRouter.presentedError,
            actions: {
                Button {
                    pageRouter.presentedError = nil
                } label: {
                    Text("OK", comment: "Button title")
                }
            }
        )
        .tabItem {
            Label(title: { Text(pageSpec.title) }, icon: { tabIcon })
        }
    }

    @ViewBuilder func modalView(for destination: ModalDestination) -> some View {
        switch destination {
        case let .itemCreate(viewModel):
            ItemForm(viewModel: viewModel)
        case let .itemDetails(itemSubject):
            ItemDetailsView(
                itemViewModel: ObservableSubject<Item>(subject: itemSubject),
                imageDownload: appService.value.downloadImage
            )
        case .collectionCreate:
            NewCollectionForm()
        case let .profileEdit(userProfileSubject):
            ProfileEditView(viewModel: ObservableSubject<UserProfile>(subject: userProfileSubject))
        }
    }
}

extension DestinationType {
    var pageType: PageType {
        switch self {
        case .userProfile:
            return .userProfile
        case .unknown:
            return .unknown
        }
    }
}
