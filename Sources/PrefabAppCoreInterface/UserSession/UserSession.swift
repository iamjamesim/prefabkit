import Foundation

/// An object that represents an active user session.
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

public struct UserSessionScopedServices {
    public let appService: AppServiceProtocol
    public let userProfileService: UserProfileServiceProtocol

    public init(appService: AppServiceProtocol, userProfileService: UserProfileServiceProtocol) {
        self.appService = appService
        self.userProfileService = userProfileService
    }
}
