import PrefabAppCoreInterface
import SwiftUI

/// The view model for `ItemFormTextField`.
@MainActor
final class ItemFormTextFieldViewModel: ObservableObject, ItemFormFieldViewModel {
    let field: FormFieldSpec
    weak var delegate: ItemFormFieldDelegate?

    /// The text field placeholder.
    var placeholder: String {
        let placeholder = field.placeholder ?? field.name.capitalized
        if field.required {
           return placeholder
        } else {
            return "\(placeholder) (Optional)"
        }
    }

    /// The text input.
    @Published var textInput: String = "" {
        didSet {
            delegate?.onInputStateChange()
        }
    }

    private var trimmedTextInput: String {
        textInput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isEmpty: Bool {
        trimmedTextInput.isEmpty
    }

    /// Creates a new `ItemFormTextFieldViewModel` instance.
    /// - Parameter field: An item form field.
    init(field: FormFieldSpec) {
        self.field = field
    }

    func addInput(toRequest request: inout MultipartRequest) throws {
        if !trimmedTextInput.isEmpty {
            request.addField(
                MultipartRequest.Field(
                    name: field.name,
                    value: trimmedTextInput
                )
            )
        }
    }
}
