import PrefabAppCoreInterface
import SwiftUI

struct UnknownItemTypeView: View {
    let layout: ItemCardLayout

    var body: some View {
        VStack(alignment: .center, spacing: layout.textVerticalSpacing) {
            Text("Unknown item type")
                .font(AppFont.font(withSize: layout.textSize, weight: .semibold))
                .foregroundColor(AppColor.contentPrimary.color)
            Text("Please update to the latest version.")
                .font(AppFont.font(withSize: layout.textSize, weight: .regular))
                .foregroundColor(AppColor.contentPrimary.color)
        }
        .padding(8)
        .frame(width: layout.cardWidth, height: layout.cardWidth)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(AppColor.border.color, lineWidth: 1)
        )
    }
}

struct UnknownItemTypeView_Previews: PreviewProvider {
    struct ImageLoadingError: Error {}

    struct PreviewContainer: View {
        let cardSpec: ItemCardSpec
        let cardWidth: CGFloat

        var body: some View {
            UnknownItemTypeView(
                layout: .init(cardWidth: cardWidth)
            )
            .padding(16)
        }
    }

    static var previews: some View {
        PreviewVariants {
            ScrollView {
                VStack {
                    PreviewContainer(cardSpec: .init(iconButtons: [], menuItems: []), cardWidth: 120)
                        .padding(16)
                    PreviewContainer(cardSpec: .init(iconButtons: [], menuItems: []), cardWidth: 160)
                        .padding(16)
                    PreviewContainer(cardSpec: .init(iconButtons: [], menuItems: []), cardWidth: 240)
                        .padding(16)
                    PreviewContainer(cardSpec: .init(iconButtons: [], menuItems: []), cardWidth: 320)
                        .padding(16)
                }
            }
        }
    }
}
