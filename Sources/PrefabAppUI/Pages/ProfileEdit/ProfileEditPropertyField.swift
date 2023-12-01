import SwiftUI

/// A button that shows a profile property label and value.
struct ProfileEditPropertyField: View {
    /// A profile property type.
    let propertyType: ProfileEditPropertyType
    /// A property value.
    let value: String
    /// A closure that is called when the button is tapped.
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(propertyType.formInputType.label)
                    .font(.footnote.weight(.semibold))
                Text(value)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .tint(AppColor.contentPrimary.color)
        }
    }
}
