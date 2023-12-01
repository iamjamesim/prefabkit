import PrefabAppCoreInterface
import SwiftUI

/// A view that allows the user to edit their profile.
struct ProfileEditView: View {
    struct NavigationDestination {
        let propertyType: ProfileEditPropertyType
        let initialValue: String
        let updateProperty: (String) async throws -> Void
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userProfileService: EnvironmentValueContainer<UserProfileServiceProtocol>

    /// An `ObservableSubject` that contains a user profile.
    @StateObject var viewModel: ObservableSubject<UserProfile>

    @State private var navigationPath: [NavigationDestination] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 0) {
                    Divider()
                    ProfileEditPictureSection(userProfile: viewModel.value)
                    Divider()
                    propertyField(
                        propertyType: .username,
                        value: viewModel.value.username,
                        updateProperty: { username in
                            try await userProfileService.value.updateUsername(username)
                        }
                    )
                    Divider()
                    propertyField(
                        propertyType: .displayName,
                        value: viewModel.value.displayName,
                        updateProperty: { displayName in
                            try await userProfileService.value.updateDisplayName(displayName)
                        }
                    )
                    Divider()
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                ProfileEditPropertyForm(
                    propertyType: destination.propertyType,
                    input: destination.initialValue,
                    updateProperty: destination.updateProperty,
                    dismiss: {
                        navigationPath.removeLast()
                    }
                )
            }
            .navigationTitle("Edit profile")
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

    @ViewBuilder private func propertyField(
        propertyType: ProfileEditPropertyType,
        value: String,
        updateProperty: @escaping (String) async throws -> Void
    ) -> some View {
        ProfileEditPropertyField(
            propertyType: propertyType,
            value: value,
            onTap: {
                navigationPath.append(
                    ProfileEditView.NavigationDestination(
                        propertyType: propertyType,
                        initialValue: value,
                        updateProperty: updateProperty
                    )
                )
            }
        )
    }
}

extension ProfileEditView.NavigationDestination: Hashable {
    static func == (lhs: ProfileEditView.NavigationDestination, rhs: ProfileEditView.NavigationDestination) -> Bool {
        lhs.propertyType == rhs.propertyType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(propertyType)
    }
}
