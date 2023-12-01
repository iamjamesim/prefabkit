import Foundation
import PrefabAppCoreInterface

/// An object that represents an active user session.
@MainActor
public final class UserSession: ObservableObject {
    /// A user profile subject for the current user.
    public let userProfileSubject: UserProfileSubject

    public var userID: String {
        userProfileSubject.id
    }

    /// Creates a new `UserSession` instance.
    /// - Parameter userProfileSubject: A user profile subject for the current user.
    public init(userProfileSubject: UserProfileSubject) {
        self.userProfileSubject = userProfileSubject
    }
}
