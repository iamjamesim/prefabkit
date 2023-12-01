import Foundation

public protocol UnknownDecodable: Decodable, RawRepresentable, CaseIterable, Equatable {
    static var unknown: Self { get }
}

extension UnknownDecodable where RawValue: Decodable {
    public static var allKnownCases: [Self] {
        allCases.filter { .unknown != $0 }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        self = Self(rawValue: rawValue) ?? .unknown
    }
}
