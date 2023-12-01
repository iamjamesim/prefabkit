import Combine
import Foundation
import PrefabAppCoreInterface

extension UserProfile: AppObject {
    static let objectType: AppObjectType = .userProfile

    init(dto: UserProfileDTO, relatedObjectProvider: AppObjectProvider) throws {
        self.init(
            id: dto.id,
            username: dto.username,
            displayName: dto.displayName,
            avatarUrl: dto.avatarUrl,
            bio: dto.bio,
            insertedAt: dto.insertedAt
        )
    }
}
