import PrefabAppUtilities
import SwiftUI

/// An enum representing all icons used in the app UI.
public enum Icon: String, CaseIterable, Codable, UnknownDecodable {
    case add
    case addCollection
    case bookmark
    case explore
    case globe
    case heart
    case home
    case image
    case news
    case person
    case personCircle
    case star
    case thumbsUp
    case warning
    case unknown

    /// An outline image name.
    private var outlineImageName: String {
        "\(rawValue)-outline"
    }

    /// A fill image name.
    private var fillImageName: String {
        "\(rawValue)-fill"
    }

    /// A SwiftUI Image for the outline variant.
    public func outlineImage(bundle: Bundle) -> Image {
        Image(outlineImageName, bundle: bundle)
            .renderingMode(.template)
    }

    /// A SwiftUI Image for the fill variant.
    public func fillImage(bundle: Bundle) -> Image {
        if let uiImage = UIImage(named: fillImageName, in: bundle, with: nil) {
            return Image(uiImage: uiImage)
                .renderingMode(.template)
        } else {
            return outlineImage(bundle: bundle)
        }
    }

    public init(name: String) {
        self = Icon(rawValue: name) ?? Icon.unknown
    }
}
