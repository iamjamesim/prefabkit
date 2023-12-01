import PhotosUI
import PrefabAppCoreInterface
import SwiftUI

/// An object that loads data from a `PhotosPickerItem`.
@MainActor
final class PhotosPickerItemLoader: ObservableObject {
    @Published private(set) var loadingState: LoadingState<UIImage> = .loading
    var loadedImage: UIImage? {
        if case let .loaded(image) = loadingState {
            return image
        } else {
            return nil
        }
    }

    /// A `PhotosPickerItem` to load.
    let photosPickerItem: PhotosPickerItem
    private let analytics: AnalyticsProtocol

    /// Creates a new `PhotosPickerItemLoader` instance.
    /// - Parameter photosPickerItem: A `PhotosPickerItem` to load.
    /// - Parameter analytics: An `AnalyticsProtocol` instance.
    init(photosPickerItem: PhotosPickerItem, analytics: AnalyticsProtocol) {
        self.photosPickerItem = photosPickerItem
        self.analytics = analytics

        loadMediaItem()
    }

    private func loadMediaItem() {
        Task {
            do {
                loadingState = .loaded(try await photosPickerItem.loadMediaItem().value)
            } catch {
                analytics.logError(error)
                loadingState = .error
            }
        }
    }
}
