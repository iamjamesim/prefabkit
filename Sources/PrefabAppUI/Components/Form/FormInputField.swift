import SwiftUI

/// A form input field.
struct FormInputField: View {
    /// A binding to the text input.
    @Binding var input: String
    /// An input type.
    let inputType: FormInputType

    var body: some View {
        TextField(inputType.label, text: $input)
            .textContentType(inputType.textContentType)
            .keyboardType(inputType.keyboardType)
            .textInputAutocapitalization(inputType.textInputAutocapitalization)
            .autocorrectionDisabled(inputType.autocorrectionDisabled)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder()
                    .foregroundColor(AppColor.border.color)
            )
    }
}
