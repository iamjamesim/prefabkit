import SwiftUI

enum AppFont {
    /// Returns the standard font with the specified size and weight.
    static func font(withSize size: CGFloat, weight: Font.Weight) -> Font {
        Font.system(size: size, weight: weight)
    }
}
