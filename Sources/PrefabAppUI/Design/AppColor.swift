import SwiftUI

/// An enum representing all colors used in the app UI.
public enum AppColor: String, CaseIterable {
    // MARK: Usage Colors
    case background
    case border
    case buttonPrimaryBackground
    case buttonPrimaryForeground
    case buttonSecondaryBackground
    case buttonSecondaryForeground
    case contentPrimary
    case contentSecondary
    case imagePlaceholder

    // MARK: Palette Colors
    case black
    case blue
    case clear
    case red
    case white

    /// A SwiftUI Color.
    public var color: Color {
        switch self {
        case .buttonSecondaryForeground:
            return Color.primary
        case .contentPrimary:
            return Color.primary
        case .contentSecondary:
            return Color.secondary
        case .background,
             .border,
             .buttonPrimaryBackground,
             .buttonPrimaryForeground,
             .buttonSecondaryBackground,
             .imagePlaceholder:
            return Color(rawValue, bundle: .module)
        case .black:
            return Color.black
        case .blue:
            return Color.blue
        case .clear:
            return Color.clear
        case .red:
            return Color.red
        case .white:
            return Color.white
        }
    }
}

struct AppColor_Previews: PreviewProvider {
    static var previews: some View {
        PreviewVariants {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16, alignment: .bottom)], spacing: 16) {
                    ForEach(AppColor.allCases, id: \.self) { color in
                        LabeledPreview(label: color.rawValue) {
                            color.color
                                .frame(width: 120, height: 120)
                                .padding(.bottom, 8)
                        }
                    }
                }
                .padding(16)
            }
        }
    }
}
