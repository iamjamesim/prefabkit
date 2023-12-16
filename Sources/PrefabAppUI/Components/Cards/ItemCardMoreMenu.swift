import PrefabAppCoreInterface
import SwiftUI

struct ItemCardMoreMenu: View {
    /// Menu items.
    let menuItems: [ItemCardMenuItem]
    /// A closure that is called when a menu item is tapped.
    let onMenuItemTap: (ItemCardMenuItem.Action) -> Void

    @State private var isPresented: Bool = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .medium))
                .frame(width: 32, height: 32)
        }
        .confirmationDialog("Item Actions", isPresented: $isPresented, titleVisibility: .hidden, actions: {
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
        })
    }
}
