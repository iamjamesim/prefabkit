import Foundation

/// A struct that represents an app specification.
public struct AppSpec: Codable {
    /// An array of `PageSpec` structs.
    public let pages: [PageSpec]
    /// An array of `DestinationPageSpec` structs.
    public let destinationPages: [DestinationPageSpec]

    public init(pages: [PageSpec], destinationPages: [DestinationPageSpec]) {
        self.pages = pages
        self.destinationPages = destinationPages
    }
}
