import SwiftUI
import PrefabAppCoreInterface

/// An enum representing destinations that can be presented modally.
enum ModalDestination: Identifiable {
    case itemCreate(ItemFormViewModel)
    case itemDetails(ItemSubject)
    case collectionCreate
    case profileEdit(UserProfileSubject)

    var id: String {
        switch self {
        case .itemCreate:
            return "itemCreate"
        case let .itemDetails(itemSubject):
            return "itemDetails_\(itemSubject.id)"
        case .collectionCreate:
            return "collectionCreate"
        case .profileEdit:
            return "profileEdit"
        }
    }
}
