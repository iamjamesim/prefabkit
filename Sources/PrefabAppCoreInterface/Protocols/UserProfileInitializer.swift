import Foundation

/// A protocol for a service that either gets or creates the signed in user's profile at the start of a user session.
public protocol UserProfileInitializerProtocol {
    /// Gets the current user profile.
    /// - Returns: The current user profile.
    /// - Throws: `UserProfileInitializerError.profileNotFound` if a profile does not exist for the current user.
    func currentUserProfile() async throws -> UserProfile

    /// Creates a new user profile.
    /// - Parameters:
    ///   - username: A username.
    ///   - displayName: A display name.
    /// - Returns: The created user profile.
    func createUserProfile(username: String, displayName: String) async throws -> UserProfile
}

/// An error that can be thrown by `UserProfileInitializerProtocol`.
public enum UserProfileInitializerError: Error {
    /// The requested user profile was not found.
    case profileNotFound
}
