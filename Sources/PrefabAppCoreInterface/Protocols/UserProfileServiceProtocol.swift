import Foundation
import UIKit

/// A protocol for a service that coordinates user profile operations in an app.
public protocol UserProfileServiceProtocol {
    /// Returns a user profile given a user ID.
    /// - Parameter userID: A user ID.
    func userProfile(userID: String) async throws -> UserProfileSubject

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
