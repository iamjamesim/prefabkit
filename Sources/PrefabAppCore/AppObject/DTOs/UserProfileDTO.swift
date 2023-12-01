import Foundation
import PrefabAppCoreInterface

struct UserProfileDTO: AppObjectDTO {
    typealias Object = UserProfile

    let id: String
    let username: String
    let displayName: String
    let avatarUrl: URL?
    let bio: String?
    let insertedAt: Date
}
