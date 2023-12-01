import Foundation

/// A struct that represents a destination page specification.
public struct DestinationPageSpec: Codable {
    /// A destination type.
    public let destinationType: DestinationType
    /// Subpages to show in the content section of the page.
    public let subpages: [SubpageSpec]
}
