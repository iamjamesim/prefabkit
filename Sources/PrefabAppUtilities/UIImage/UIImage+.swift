import UIKit

extension UIImage {
    /// Returns a new image that is downsized to the specified width.
    /// - Parameter targetWidth: The target width of the new image.
    /// - Returns: A new image that is downsized to the specified width.
    public func downsizedIfNeeded(toWidth targetWidth: CGFloat) -> UIImage {
        if size.width <= targetWidth {
            return self
        }
        let targetHeight = round(targetWidth * size.height / size.width)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: targetWidth, height: targetHeight))
        return renderer.image { context in
            draw(in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
        }
    }

    /// Returns a data object that contains the image in JPEG format.
    ///
    /// Calls `jpegData(compressionQuality:)`, and throws an error if the result is nil.
    /// - Parameter compressionQuality: The compression quality of the resulting JPEG image. See `jpegData(compressionQuality:)` for more information.
    /// - Returns: A data object that contains the image in JPEG format.
    public func validJpegData(compressionQuality: CGFloat) throws -> Data {
        guard let data = jpegData(compressionQuality: compressionQuality) else {
            throw ImageOperationError.invalidFileFormat
        }
        return data
    }
}

/// An error encountered during an image operation.
public enum ImageOperationError: Error, LocalizedError {
    /// The underlying image file format is invalid.
    case invalidFileFormat

    public var errorDescription: String? {
        switch self {
        case .invalidFileFormat:
            return String(localized: "Invalid File Format", comment: "Error description")
        }
    }
}
