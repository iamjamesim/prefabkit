import Foundation
import PrefabAppCoreInterface

enum PreviewData {
    static let profileImageURL = URL(string: "https://images.unsplash.com/photo-1517423440428-a5a00ad493e8?auto=format&fit=crop&q=80&w=2683&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!
    static let itemImageURL = URL(string: "https://images.unsplash.com/photo-1568640347023-a616a30bc3bd?auto=format&fit=crop&q=80&w=2946&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!

    static let userProfile = UserProfile(
        id: "1",
        username: "johndoe",
        displayName: "John Doe",
        avatarUrl: PreviewData.profileImageURL,
        bio: "Could be anyone, really.",
        insertedAt: Date()
    )

    static let item = Item(
        id: "1",
        itemType: .product,
        name: "Dog Treats",
        description: "$12",
        body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        imagePath: "/item/1/image",
        url: nil,
        creator: .init(userProfile),
        isLiked: false,
        isSaved: false,
        insertedAt: Date(),
        updatedAt: Date()
    )
}
