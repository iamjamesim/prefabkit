import SwiftUI

/// A toolbar icon that shows a system image.
struct ToolbarSystemIcon: View {
    /// A system image name.
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 16).weight(.medium))
            .foregroundColor(AppColor.contentPrimary.color)
            .frame(width: 32, height: 32)
    }
}

struct ToolbarSystemIcon_Previews: PreviewProvider {
    static var previews: some View {
        PreviewVariants {
            ToolbarSystemIcon(systemName: "xmark")
        }
    }
}
