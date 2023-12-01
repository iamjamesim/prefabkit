import PrefabAppCoreInterface
import SwiftUI

struct ItemCardMoreMenu: View {
    /// Menu items.
    let menuItems: [ItemCardMenuItem]
    /// A closure that is called when a menu item is tapped.
    let onMenuItemTap: (ItemCardMenuItem.Action) -> Void

    var body: some View {
        Menu {
            ForEach(menuItems, id: \.action) { menuItem in
                switch menuItem.action {
                case .delete:
                    Button(role: .destructive) {
                        onMenuItemTap(menuItem.action)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                case .unknown:
                    EmptyView()
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .medium))
                .frame(width: 32, height: 32)
        }
    }
}
