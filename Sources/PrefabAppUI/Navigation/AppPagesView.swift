import PrefabAppCoreInterface
import SwiftUI

/// A container view for an app's top-level pages.
public struct AppPagesView: View {
    private let analytics: AnalyticsProtocol
    private let appService: AppServiceProtocol
    private let iconAssetBundle: Bundle
    private let userProfileService: UserProfileServiceProtocol
    private let userSession: UserSession

    @State private var state: LoadingState<AppSpec> = .loading
    @State private var tabSelection = 0

    /// Creates a new `AppPagesView` instance with the provided dependencies.
    /// - Parameters:
    ///   - analytics: An `AnalyticsProtocol` instance.
    ///   - appService: An `AppServiceProtocol` instance.
    ///   - iconAssetBundle: A bundle that contains icon assets.
    ///   - userProfileService: A `UserProfileServiceProtocol` instance.
    ///   - userSession: A `UserSession` instance.
    public init(
        analytics: AnalyticsProtocol,
        appService: AppServiceProtocol,
        iconAssetBundle: Bundle,
        userProfileService: UserProfileServiceProtocol,
        userSession: UserSession
    ) {
        self.analytics = analytics
        self.appService = appService
        self.iconAssetBundle = iconAssetBundle
        self.userProfileService = userProfileService
        self.userSession = userSession
    }

    public var body: some View {
        DataLoadingView(
            load: { () async throws -> AppSpec in
                try await appService.appSpec()
            }
        ) { appSpec in
            if appSpec.pages.count > 1 {
                TabView(selection: $tabSelection) {
                    ForEach(Array(appSpec.pages.enumerated()), id: \.element.id) { index, pageSpec in
                        pageView(
                            pageSpec: pageSpec,
                            destinationPageSpecs: appSpec.destinationPages,
                            isSelected: tabSelection == index
                        )
                        .tag(index)
                    }
                }
                .tint(AppColor.contentPrimary.color)
            } else if let pageSpec = appSpec.pages.first {
                pageView(
                    pageSpec: pageSpec,
                    destinationPageSpecs: appSpec.destinationPages,
                    isSelected: true
                )
            }
        }
        .environmentObject(EnvironmentValueContainer(value: analytics))
        .environmentObject(EnvironmentValueContainer(value: appService))
        .environmentObject(EnvironmentValueContainer(value: iconAssetBundle))
        .environmentObject(EnvironmentValueContainer(value: userProfileService))
        .environmentObject(userSession)
    }

    @ViewBuilder func pageView(
        pageSpec: PageSpec,
        destinationPageSpecs: [DestinationPageSpec],
        isSelected: Bool
    ) -> some View {
        TabRootView(
            pageSpec: pageSpec,
            destinationPageSpecs: destinationPageSpecs,
            isSelected: isSelected
        )
        .tint(Color.accentColor) // Undo tint set on TabView.
    }
}
