import PrefabAppCoreInterface
import SwiftUI

/// A view that contains subpages that display content query results.
struct SubpagesView<Header: View>: View {
    @EnvironmentObject private var appService: EnvironmentValueContainer<AppServiceProtocol>
    @EnvironmentObject private var pageContext: EnvironmentValueContainer<PageContext>
    @EnvironmentObject private var pageRouter: PageRouter

    /// Subpages to show.
    let subpages: [SubpageSpec]
    let header: () -> Header

    @Namespace private var animationNamespace
    @State private var tabSelection = 0
    @State private var tabScrollPositions = [Int: CGFloat]()
    @State private var tabScrollRequests = [Int: SubpageView.ScrollToRequest]()
    @State private var headerOffsetY: CGFloat = 0
    @State private var headerHeight: CGFloat = 0
    @State private var subpagesTabBarHeight: CGFloat = 0

    private var subpagesTabbarOffsetY: CGFloat {
        max(0, headerOffsetY + headerHeight)
    }

    init(@ViewBuilder header: @escaping () -> Header = { EmptyView() }, subpages: [SubpageSpec]) {
        self.header = header
        self.subpages = subpages
    }

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $tabSelection.animation(tabSelectionAnimation)) {
                ForEach(Array(subpages.enumerated()), id: \.element.id) { index, subpage in
                    SubpageView(
                        subpageSpec: subpage,
                        headerHeight: headerHeight,
                        onContentFrameChange: onContentFrameChange,
                        scrollToRequest: tabScrollRequests[index]
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: tabSelection) { newSelection in
                let requestID = (tabScrollRequests[newSelection]?.id ?? 0) + 1
                if headerOffsetY > -headerHeight {
                    // If header is partially or fully visible, the top of the content has to be aligned to the bottom
                    // of the header. To achieve this simply, restore header and scroll offsets to 0.
                    tabScrollRequests[newSelection] = .init(value: .top, id: requestID)
                    headerOffsetY = 0
                } else {
                    // If the header is fully hidden, scroll up to align the top of the content to the top of the view
                    // only if the content is detached from the top of the view.
                    let tabScrollPosition = tabScrollPositions[newSelection] ?? 0
                    if tabScrollPosition > -headerHeight {
                        tabScrollRequests[newSelection] = .init(value: .contentToTop, id: requestID)
                    } else {
                        tabScrollRequests[newSelection] = nil
                    }
                }
            }
            .padding(.top, subpagesTabBarHeight)
            subpagesTabBar
            headerView
        }
        .clipped() // Clip offset header within container view bounds.
    }

    @ViewBuilder private var headerView: some View {
        header()
            .background(AppColor.background.color)
            .overlay(
                GeometryReader { geometryProxy in
                    Color.clear.preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                },
                alignment: .center
            )
            .onPreferenceChange(SizePreferenceKey.self) { size in
                headerHeight = size.height
            }
            .offset(y: headerOffsetY)
    }

    @ViewBuilder private var subpagesTabBar: some View {
        if subpages.count > 1 {
            HStack(spacing: 8) {
                ForEach(Array(subpages.enumerated()), id: \.element.id) { index, subpage in
                    Button {
                        withAnimation(tabSelectionAnimation) {
                            tabSelection = index
                        }
                    } label: {
                        Text(subpage.title)
                            .font(.headline)
                            .foregroundColor(
                                tabSelection == index
                                ? AppColor.contentPrimary.color
                                : AppColor.contentSecondary.color
                            )
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                Group {
                                    if tabSelection == index {
                                        Capsule()
                                            .frame(height: 2)
                                            .matchedGeometryEffect(id: "underline", in: animationNamespace)
                                    }
                                },
                                alignment: .bottom
                            )
                    }
                    .tint(AppColor.contentPrimary.color)
                }
            }
            .padding(.horizontal, 24)
            .background(AppColor.background.color)
            .overlay(
                GeometryReader { geometryProxy in
                    Color.clear.preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                },
                alignment: .center
            )
            .onPreferenceChange(SizePreferenceKey.self) { size in
                subpagesTabBarHeight = size.height
            }
            .offset(y: subpagesTabbarOffsetY)
        }
    }

    private func onContentFrameChange(frame: CGRect, scrollViewHeight: CGFloat) {
        // Do nothing if the content height is shorter than the scroll view height.
        guard frame.size.height > scrollViewHeight else {
            return
        }

        // Scroll content can scroll as far beyond the origin as the content height that exceeds the view height.
        let scrollBottomOriginY = -(frame.size.height - scrollViewHeight)
        // Clamp to ignore over-scrolled positions for moving the header.
        let originY = max(scrollBottomOriginY, min(frame.origin.y, 0))
        // Make header track scroll view origin.
        headerOffsetY = originY
        // Update scroll position for the current tab.
        tabScrollPositions[tabSelection] = originY
    }
}

private let tabSelectionAnimation = Animation.easeInOut(duration: 0.2)

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let nextValue = nextValue()
        value.width += nextValue.width
        value.height += nextValue.height
    }
}
