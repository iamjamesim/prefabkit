import SwiftUI

/// A floating action button.
struct FloatingActionButton: View {
    @EnvironmentObject private var iconAssetBundle: EnvironmentValueContainer<Bundle>

    /// An icon to use as the button image.
    let icon: Icon
    /// A button action.
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            icon.outlineImage(bundle: iconAssetBundle.value)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(AppColor.buttonPrimaryForeground.color)
                .frame(width: 56, height: 56)
                .background(Circle().fill(AppColor.buttonPrimaryBackground.color))
        }
        .padding(24)
        .shadow(color: AppColor.buttonPrimaryBackground.color.opacity(0.14), radius: 5, y: 8)
    }
}

struct FloatingActionButton_Previews: PreviewProvider {
    static var previews: some View {
        PreviewVariants {
            FloatingActionButton(icon: .add) {}
        }
    }
}
