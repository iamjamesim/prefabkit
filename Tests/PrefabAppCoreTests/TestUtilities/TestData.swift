@testable import PrefabAppCore

import Foundation
import PrefabAppCoreInterface

enum TestData {
    static let itemDTO = ItemDTO(
        id: "1",
        itemType: .product,
        name: "Hello, World!",
        description: nil,
        body: nil,
        imagePath: nil,
        url: nil,
        creatorId: "1",
        isLiked: false,
        isSaved: false,
        insertedAt: Date(),
        updatedAt: Date()
    )
    static let savedItemDTO = ItemDTO(
        id: "1",
        itemType: .product,
        name: "Hello, World!",
        description: nil,
        body: nil,
        imagePath: nil,
        url: nil,
        creatorId: "1",
        isLiked: false,
        isSaved: true,
        insertedAt: Date(),
        updatedAt: Date()
    )
    static let likedItemDTO = ItemDTO(
        id: "1",
        itemType: .socialPost,
        name: "Hello, World!",
        description: nil,
        body: nil,
        imagePath: nil,
        url: nil,
        creatorId: "1",
        isLiked: true,
        isSaved: false,
        insertedAt: Date(),
        updatedAt: Date()
    )

    static let profileDTO = UserProfileDTO(
        id: "1",
        username: "johndoe",
        displayName: "John Doe",
        avatarUrl: nil,
        bio: nil,
        insertedAt: Date()
    )

    static let profileSubject = UserProfileSubject(try! .init(
        dto: profileDTO,
        relatedObjectProvider: TestNoopObjectProvider()
    ))
}
