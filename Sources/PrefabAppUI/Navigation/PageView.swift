import PrefabAppCoreInterface
import SwiftUI

/// A view that displays the contents of a page.
struct PageView: View {
    @EnvironmentObject private var userSession: UserSession

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
                ProfileView(userProfileSubject: userSession.userProfileSubject, subpages: subpages)
            case .unknown:
                UnknownPageTypeView()
            }
        }
        .environmentObject(EnvironmentValueContainer(value: pageContext))
    }
}
