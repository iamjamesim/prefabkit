import PrefabAppCoreInterface
import Foundation

/// A protocol conformed by all item form field view models.
@MainActor
protocol ItemFormFieldViewModel: AnyObject {
    /// An `ItemFormFieldDelegate`.
    var delegate: ItemFormFieldDelegate? { get set }
    /// An item form field.
    var field: FormFieldSpec { get }
    /// A Boolean value that indicates whether the field is empty.
    var isEmpty: Bool { get }
    /// Adds the input value to the request.
    func addInput(toRequest request: inout MultipartRequest) throws
}

extension ItemFormFieldViewModel {
    /// A Boolean value that indicates whether the field is required and empty.
    var isRequiredAndEmpty: Bool {
        field.required && isEmpty
    }
}

/// A delegate for an item form field.
protocol ItemFormFieldDelegate: AnyObject {
    /// A method that is called when the input state changes.
    func onInputStateChange()
}
