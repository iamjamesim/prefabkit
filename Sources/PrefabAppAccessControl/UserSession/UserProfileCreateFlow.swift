import PrefabAppCoreInterface
import PrefabAppUI
import SwiftUI

/// A view that contains the user profile creation flow.
struct UserProfileCreateFlow: View {
    private enum NavigationDestination: Hashable {
        case nameInput
    }

    @EnvironmentObject private var userProfileService: EnvironmentValueContainer<UserProfileServiceProtocol>

    @State private var navigationPath: [NavigationDestination] = []

    @State private var username: String = ""
    @State private var displayName: String = ""

    /// A closure that is called when the user profile is created successfully.
    let onProfileCreate: (UserProfileSubject) -> Void

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SingleInputForm(
                inputType: .username,
                input: $username,
                submitButtonTitle: String(localized: "Continue", comment: "Button title"),
                submit: {
                    // TODO: perform input validation before proceeding
                    navigationPath.append(.nameInput)
                },
                onSuccess: {}
            )
            .navigationTitle("Create account")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .nameInput:
                    SingleInputForm(
                        inputType: .name,
                        input: $displayName,
                        submitButtonTitle: String(localized: "Create", comment: "Button title"),
                        submit: {
                            // TODO: perform input validation before submitting
                            try await userProfileService
                                .value.createUserProfile(
                                    username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                                    displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines)
                                )
                        },
                        onSuccess: { newProfile in
                            onProfileCreate(newProfile)
                        }
                    )
                    .navigationTitle("Create account")
                }
            }
        }
        .tint(AppColor.contentPrimary.color)
    }
}
