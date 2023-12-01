import PrefabAppCoreInterface
import PhotosUI
import SwiftUI

/// The view model for `ItemFormImagePicker`.
@MainActor
final class ItemFormImagePickerViewModel: ObservableObject, ItemFormFieldViewModel {
    let field: FormFieldSpec
    weak var delegate: ItemFormFieldDelegate?

    private let analytics: AnalyticsProtocol

    /// The selected image loader.
    @Published private(set) var selectedImageLoader: PhotosPickerItemLoader? {
        didSet {
            delegate?.onInputStateChange()
        }
    }

    /// The selected photos picker item.
    var selectedPhotosPickerItem: PhotosPickerItem? {
        get {
            selectedImageLoader?.photosPickerItem
        }
        set {
            if let newValue {
                selectedImageLoader = PhotosPickerItemLoader(photosPickerItem: newValue, analytics: analytics)
            } else {
                selectedImageLoader = nil
            }
        }
    }

    var isEmpty: Bool {
        selectedImageLoader?.loadedImage == nil
    }

    /// Creates a new `ItemFormImagePickerViewModel` instance.
    /// - Parameter field: An item form field.
    /// - Parameter analytics: An `AnalyticsProtocol` instance.
    init(field: FormFieldSpec, analytics: AnalyticsProtocol) {
        self.field = field
        self.analytics = analytics
    }

    func addInput(toRequest request: inout MultipartRequest) throws {
        if let image = selectedImageLoader?.loadedImage {
            let fileData = try image.downsizedIfNeeded(toWidth: 480).validJpegData(compressionQuality: 1)
            request.addFile(
                MultipartRequest.File(
                    partName: field.name,
                    fileName: UUID().uuidString,
                    mimeType: .jpeg,
                    fileData: fileData
                )
            )
        }
    }
}
