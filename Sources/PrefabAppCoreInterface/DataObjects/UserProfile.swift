import Combine
import Foundation

public struct UserProfile: Identifiable, Hashable {
    public let id: String
    public let username: String
    public let displayName: String
    public let avatarUrl: URL?
    public let bio: String?
    public let insertedAt: Date

    public init(
        id: String,
        username: String,
        displayName: String,
        avatarUrl: URL?,
        bio: String?,
        insertedAt: Date
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.insertedAt = insertedAt
    }
}

public typealias UserProfileSubject = CurrentValueSubject<UserProfile, Never>
