import SwiftUI

/// A navigation bar for the item details page.
struct ItemDetailsNavigationBar: View {
    static let height: CGFloat = 48

    @Environment(\.dismiss) private var dismiss

    /// The opacity of the navigation bar.
    let opacity: CGFloat

    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColor.contentPrimary.color)
            }
            .buttonStyle(NavigationBarButtonStyle(navigationBarOpacity: opacity))
            Spacer()
        }
        .padding(.horizontal, 8)
        .background(
            AppColor.background.color
                .overlay(Divider(), alignment: .bottom)
                .opacity(opacity)
                .edgesIgnoringSafeArea(.top)
        )
    }
}

private struct NavigationBarButtonStyle: ButtonStyle {
    let navigationBarOpacity: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(AppColor.background.color)
                    .overlay(
                        Circle()
                            .strokeBorder(AppColor.border.color, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.14), radius: 4, y: 4)
                    .opacity(1 - navigationBarOpacity)
            )
            .frame(width: ItemDetailsNavigationBar.height, height: ItemDetailsNavigationBar.height)
    }
}
