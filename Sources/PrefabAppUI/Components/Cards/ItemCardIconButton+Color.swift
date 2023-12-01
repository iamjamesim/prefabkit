import PrefabAppCoreInterface
import SwiftUI

extension ItemCardIconButton {
    var activeColorOverride: Color? {
        switch Icon(name: icon) {
        case .heart:
            return AppColor.red.color
        case .thumbsUp:
            return AppColor.blue.color
        default:
            return nil
        }
    }
}
