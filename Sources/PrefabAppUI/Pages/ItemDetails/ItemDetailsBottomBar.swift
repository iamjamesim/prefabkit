import SwiftUI

/// A bottom bar that contains a CTA button for the item details page.
struct ItemDetailsBottomBar: View {
    @Environment(\.openURL) private var openURL

    /// A URL to open when the user taps the button.
    let url: URL

    var body: some View {
        HStack {
            Button {
                openURL(url)
            } label: {
                Text("Visit Site", comment: "Button title")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColor.buttonPrimaryForeground.color)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(AppColor.buttonPrimaryBackground.color)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            AppColor.background.color
                .overlay(Divider(), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }
}
