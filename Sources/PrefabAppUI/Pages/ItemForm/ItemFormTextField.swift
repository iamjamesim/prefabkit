import SwiftUI

/// An item form text field.
struct ItemFormTextField: View {
    /// An `ItemFormTextFieldViewModel`.
    @StateObject var viewModel: ItemFormTextFieldViewModel
    /// A binding to the form text field focus state.
    var focused: FocusState<String?>.Binding

    var body: some View {
        TextField(
            viewModel.placeholder,
            text: $viewModel.textInput,
            axis: .vertical
        )
        .focused(focused, equals: viewModel.field.name)
    }
}
