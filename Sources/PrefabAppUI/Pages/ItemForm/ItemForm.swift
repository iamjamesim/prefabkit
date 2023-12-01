import PrefabAppCoreInterface
import SwiftUI

/// A view that contains the item form.
struct ItemForm: View {
    @StateObject var viewModel: ItemFormViewModel

    @State private var submissionState: FormSubmissionState<Void> = .idle
    @FocusState private var focused: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.fieldViewModels, id: \.field.name) { viewModel in
                    if let viewModel = viewModel as? ItemFormTextFieldViewModel {
                        ItemFormTextField(
                            viewModel: viewModel,
                            focused: $focused
                        )
                    } else if let viewModel = viewModel as? ItemFormImagePickerViewModel {
                        ItemFormImagePicker(viewModel: viewModel)
                    }
                }
                Spacer()
            }
            .padding(16)
            .disabled(submissionState.isSubmitting)
            .onAppear {
                focused = viewModel.fieldViewModels.first {
                    $0.field.contentType == .text || $0.field.contentType == .url
                }.map {
                    $0.field.name
                }
            }
            .modifier(
                FormModalNavigationBarModifier(
                    title: viewModel.formTitle,
                    submitButtonTitle: String(localized: "Save", comment: "Navigation bar button title"),
                    isSubmitDisabled: viewModel.isSaveDisabled,
                    submissionState: $submissionState,
                    submit: {
                        try await viewModel.create()
                    }
                )
            )
        }
    }
}
