import PrefabAppCoreInterface
import SwiftUI

/// A container view that loads data for a content view.
public struct DataLoadingView<Data, Content: View>: View {
    @EnvironmentObject private var analytics: EnvironmentValueContainer<AnalyticsProtocol>

    /// A closure that performs the data load.
    let load: () async throws -> Data
    /// A content view that shows the loaded data.
    @ViewBuilder let content: (Data) -> Content

    @State private var hasLoaded: Bool = false
    @State private var state: LoadingState<Data> = .loading

    public init(load: @escaping () async throws -> Data, @ViewBuilder content: @escaping (Data) -> Content) {
        self.load = load
        self.content = content
    }

    public var body: some View {
        Group {
            switch state {
            case .loading:
                ProgressView()
                    .tint(AppColor.contentPrimary.color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error:
                LoadingErrorView {
                    Task {
                        await reload()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .loaded(data):
                content(data)
            }
        }
        .task {
            guard !hasLoaded || state.isError else {
                return
            }
            hasLoaded = true

            await reload()
        }
    }

    @MainActor
    private func reload() async {
        state = .loading
        do {
            state = .loaded(try await load())
        } catch {
            analytics.value.logError(error)
            state = .error
        }
    }
}
