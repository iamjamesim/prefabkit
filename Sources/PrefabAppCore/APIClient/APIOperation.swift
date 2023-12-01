import Foundation

/// An enum that represents an API operation.
public enum APIOperation: String {
    /// Returns an app spec.
    case appSpec
    /// Returns the current user's profile.
    case currentUserProfile
    /// Creates a new profile for the current user.
    case userProfileCreate
    /// Uploads a user profile avatar.
    case userProfileAvatarUpload
    /// Updates the current user's profile.
    case userProfileUpdate
    /// Returns the content of a page.
    case pageContent
    /// Creates an item collection.
    case itemCollectionCreate
    /// Deletes an item collection.
    case itemCollectionDelete
    /// Creates a new item.
    case itemCreate
    /// Deletes an item.
    case itemDelete
    /// Likes an item.
    case itemLike
    /// Unlikes an item.
    case itemUnlike
    /// Saves an item.
    case itemSave
    /// Unsaves an item.
    case itemUnsave
}

/// An error that can occur when performing an API operation.
enum APIOperationError: Error {
    case unexpectedResponse
}
