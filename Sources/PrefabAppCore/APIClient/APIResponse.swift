import Foundation

/// A standard API response that contains requested data objects.
///
/// The response structure is loosely based on JSON:API in the sense that objects that are related to the primary data objects (e.g. authors of articles) are
/// returned separately in the flattened and normalized `included` array. This makes it simple to update the normalized data structures in the `ObjectStore`.
///
/// On the other hand, this is not an implementation of the JSON:API spec, and should not be treated as such.
struct APIResponse<T: Decodable>: Decodable {
    /// Primary data.
    let data: T
    /// Related data objects.
    let included: [AnyAppObjectDTO]?
}
