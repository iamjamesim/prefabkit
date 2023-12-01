import PrefabAppCoreInterface
import SwiftUI

/// The view model for `ItemForm`.
@MainActor
final class ItemFormViewModel: ObservableObject {
    private let itemType: ItemType
    private let collectionID: String?
    private let appService: AppServiceProtocol

    /// The form title.
    let formTitle: String
    /// The view models for the form fields.
    let fieldViewModels: [ItemFormFieldViewModel]

    /// A Boolean value that indicates whether the save button should be disabled.
    @Published private(set) var isSaveDisabled: Bool = true

    /// Creates a new `ItemFormViewModel` instance.
    /// - Parameters:
    ///   - itemType: An item type.
    ///   - formTitle: The form title.
    ///   - fieldViewModels: The view models for the form fields.
    ///   - collectionID: A collection ID, if the item belongs to a collection.
    ///   - appService: An app service to use to create or update the item.
    init(
        itemType: ItemType,
        formTitle: String,
        fieldViewModels: [ItemFormFieldViewModel],
        collectionID: String?,
        appService: AppServiceProtocol
    ) {
        self.itemType = itemType
        self.formTitle = formTitle
        self.fieldViewModels = fieldViewModels
        self.collectionID = collectionID
        self.appService = appService

        for fieldViewModel in fieldViewModels {
            fieldViewModel.delegate = self
        }
    }

    /// Creates a new item with the form input values.
    func create() async throws {
        var multipartRequest = MultipartRequest()
        for fieldViewModel in fieldViewModels {
            try fieldViewModel.addInput(toRequest: &multipartRequest)
        }
        try await appService.createItem(withRequest: multipartRequest, itemType: itemType, collectionID: collectionID)
    }
}

extension ItemFormViewModel: ItemFormFieldDelegate {
    private var hasInvalidInputs: Bool {
        for fieldViewModel in fieldViewModels {
            if fieldViewModel.isRequiredAndEmpty {
                return true
            }
        }
        return false
    }

    func onInputStateChange() {
        self.isSaveDisabled = hasInvalidInputs
    }
}
