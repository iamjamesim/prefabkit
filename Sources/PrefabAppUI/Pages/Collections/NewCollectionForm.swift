import PrefabAppCoreInterface
import SwiftUI

/// A view that allows the user to create a new collection.
struct NewCollectionForm: View {
    private enum SubmitError: Error {
        case unexpected
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appService: EnvironmentValueContainer<AppServiceProtocol>

    @State private var input: String = ""

    var body: some View {
        NavigationStack {
            SingleInputForm(
                inputType: .name,
                input: $input,
                submitButtonTitle: String(localized: "Create", comment: "Navigation bar button title"),
                submit: {
                    try await appService.value.createItemCollection(name: input)
                },
                onSuccess: {
                    dismiss()
                }
            )
            .navigationTitle("New collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(AppColor.contentPrimary.color)
                    }
                }
            }
        }
    }
}
