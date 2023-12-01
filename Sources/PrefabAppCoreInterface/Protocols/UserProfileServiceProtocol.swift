import Foundation
import UIKit

/// A protocol for a service that coordinates user profile operations in an app.
public protocol UserProfileServiceProtocol {
    /// Gets the current user profile.
    /// - Returns: A `UserProfileSubject` containing the current user profile.
    /// - Throws: `UserProfileServiceError.profileNotFound` if a profile does not exist for the current user.
    func currentUserProfile() async throws -> UserProfileSubject

    /// Creates a new user profile.
    /// - Parameters:
    ///   - username: A username.
    ///   - displayName: A display name.
    /// - Returns: A `UserProfileSubject` containing the created user profile.
    func createUserProfile(username: String, displayName: String) async throws -> UserProfileSubject

    /// Updates the current user profile with the given username.
    /// - Parameter username: A username.
    func updateUsername(_ username: String) async throws

    /// Updates the current user profile with the given display name.
    /// - Parameter displayName: A display name.
    func updateDisplayName(_ displayName: String) async throws

    /// Updates the current user profile with the given avatar image.
    /// - Parameters:
    ///   - userID: A user ID.
    ///   - image: An avatar image.
    func updateAvatar(userID: String, image: UIImage) async throws
}

/// An error that can be thrown by `UserProfileServiceProtocol`.
public enum UserProfileServiceError: Error {
    /// The requested user profile was not found.
    case profileNotFound
}
