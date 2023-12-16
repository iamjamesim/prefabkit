import PrefabAppCoreInterface
import SwiftUI

/// A view that displays the contents of a page.
struct PageView: View {
    /// A page type.
    let pageType: PageType
    /// A page context object.
    let pageContext: PageContext
    /// Subpages to show in the content section of the page.
    let subpages: [SubpageSpec]

    var body: some View {
        Group {
            switch pageType {
            case .content:
                SubpagesView(subpages: subpages)
            case .userProfile:
                ProfileView(subpages: subpages)
            case .unknown:
                UnknownPageTypeView()
            }
        }
        .background(AppColor.background.color)
        .environmentObject(EnvironmentValueContainer(value: pageContext))
    }
}
