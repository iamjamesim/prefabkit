import Foundation

/// A struct used to decode any `AppObjectDTO` in an API response.
struct AnyAppObjectDTO {
    private enum TypeCodingKey: CodingKey {
        case type
    }

    /// A decoded `AppObjectDTO`.
    let dto: any AppObjectDTO
}

extension AnyAppObjectDTO: Decodable {
    /// Creates an `AnyAppObjectDTO` from a decoder.
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: A `DecodingError` on decoding failure.
    init(from decoder: Decoder) throws {
        let appObjectType = try decoder.container(keyedBy: TypeCodingKey.self)
            .decode(AppObjectType.self, forKey: TypeCodingKey.type)
        let container = try decoder.singleValueContainer()
        dto = try container.decode(appObjectType.dtoType)
    }
}
