import PhotosUI
import SwiftUI

/// A struct that represents a media item.
///
/// `MediaItem` is a `Transferable` implementation that represents a media item such as an image. It can be used to transfer media items between processes.
public struct MediaItem: Transferable {
    /// The underlying image.
    public let value: UIImage

    /// A `TransferRepresentation` for `MediaItem`.
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw LoadingError.imageLoadingFailure
            }
            return MediaItem(value: uiImage)
        }
    }
}

extension MediaItem {
    /// An error encountered while loading a `MediaItem`.
    enum LoadingError: Error, LocalizedError {
        /// The underlying data could not be loaded as an image.
        case imageLoadingFailure
        /// The underlying data is not a supported content type.
        case unsupportedContentType

        var errorDescription: String? {
            switch self {
            case .imageLoadingFailure:
                return String(localized: "Image Loading Failed", comment: "Error description")
            case .unsupportedContentType:
                return String(localized: "Unsupported Content Type", comment: "Error description")
            }
        }
    }
}



extension PhotosPickerItem {
    /// Loads a `MediaItem` from the `PhotosPickerItem`.
    /// - Throws: An error if the `PhotosPickerItem` cannot be loaded as a `MediaItem`.
    /// - Returns: A `MediaItem` loaded from the `PhotosPickerItem`.
    public func loadMediaItem() async throws -> MediaItem {
        guard let mediaItem = try await loadTransferable(type: MediaItem.self) else {
            throw MediaItem.LoadingError.unsupportedContentType
        }
        return mediaItem
    }
}
