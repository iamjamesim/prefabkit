import SwiftUI

/// A button that toggles between two icon states.
struct IconToggleButton: View {
    @EnvironmentObject private var iconAssetBundle: EnvironmentValueContainer<Bundle>

    /// Colors for the icon fill and outline.
    struct Colors {
        let fill: Color
        let outline: Color
    }

    /// An icon.
    let icon: Icon
    /// An icon size.
    let size: CGFloat
    /// A binding to the button's active state.
    @Binding var isActive: Bool
    /// Colors for the inactive state.
    let inactiveColors: Colors
    /// Colors for the active state.
    let activeColors: Colors

    var body: some View {
        Button {
            isActive.toggle()
        } label: {
            ZStack {
                icon.fillImage(bundle: iconAssetBundle.value)
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(isActive ? activeColors.fill : inactiveColors.fill)
                icon.outlineImage(bundle: iconAssetBundle.value)
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(isActive ? activeColors.outline : inactiveColors.outline)
            }
            .padding(8)
        }
        .padding(-8)
    }
}

struct IconToggleButton_Previews: PreviewProvider {
    struct ButtonContainer: View {
        let icon: Icon
        let inactiveColors: IconToggleButton.Colors
        let activeColors: IconToggleButton.Colors

        @State var isActive = false

        var body: some View {
            HStack {
                IconToggleButton(
                    icon: icon,
                    size: 24,
                    isActive: $isActive,
                    inactiveColors: inactiveColors,
                    activeColors: activeColors
                )
            }
        }
    }

    static var previews: some View {
        PreviewVariants {
            HStack {
                ButtonContainer(
                    icon: .heart,
                    inactiveColors: .init(fill: AppColor.black.color.opacity(0.5), outline: AppColor.white.color),
                    activeColors: .init(fill: AppColor.red.color, outline: .white)
                )
                ButtonContainer(
                    icon: .bookmark,
                    inactiveColors: .init(fill: AppColor.clear.color, outline: AppColor.contentPrimary.color),
                    activeColors: .init(fill: AppColor.contentPrimary.color, outline: AppColor.clear.color)
                )
            }
        }
    }
}
