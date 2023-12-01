import Foundation

struct ItemCardLayout {
    let cardWidth: CGFloat

    var textSize: CGFloat {
        min(max(12, (cardWidth / 10).rounded()), 18)
    }
    var textVerticalSpacing: CGFloat {
        max(4, (cardWidth / 25).roundToMultiple(of: 4))
    }
    var headerTextSize: CGFloat {
        (textSize * 0.9).rounded()
    }
    var actionButtonSize: CGFloat {
        if cardWidth > 160 {
            return 28
        } else if cardWidth > 120 {
            return 24
        } else {
            return 20
        }
    }
}
