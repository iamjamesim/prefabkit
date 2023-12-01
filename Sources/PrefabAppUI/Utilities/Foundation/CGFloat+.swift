import Foundation

extension CGFloat {
    /// Rounds the value to the nearest multiple of the given factor.
    func roundToMultiple(of factor: CGFloat) -> CGFloat {
        (self / factor).rounded() * factor
    }
}
