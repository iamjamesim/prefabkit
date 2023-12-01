import Foundation

/// A protocol conformed by all app objects.
protocol AppObject {
    /// The DTO type for the app object.
    associatedtype DTO: AppObjectDTO where DTO.Object == Self

    static var objectType: AppObjectType { get }

    /// Creates an app object for a DTO.
    ///
    /// - Parameters:
    ///     - dto: An app object DTO from an API response.
    ///     - relatedObjectProvider: An `AppObjectProvider` instance.
    /// - Throws: An error on object creation failure.
    init(dto: DTO, relatedObjectProvider: AppObjectProvider) throws
}
