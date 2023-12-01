import PrefabAppCoreInterface
import SwiftUI

/// A view that allows the user to update a profile property.
struct ProfileEditPropertyForm: View {
    /// A profile property type.
    let propertyType: ProfileEditPropertyType
    /// A state that stores the text input.
    @State var input: String
    /// A closure that performs the property update.
    let updateProperty: (String) async throws -> Void
    /// A closure that dismisses the form.
    let dismiss: () -> Void

    var body: some View {
        SingleInputForm(
            inputType: propertyType.formInputType,
            input: $input,
            submitButtonTitle: String(localized: "Save", comment: "Navigation bar title"),
            submit: {
                try await updateProperty(input)
            },
            onSuccess: {
                dismiss()
            }
        )
        .navigationTitle(propertyType.formInputType.label)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    ToolbarSystemIcon(systemName: "chevron.left")
                }
            }
        }
    }
}
