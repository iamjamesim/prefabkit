import Foundation

/// A container used to inject any value as an environment object.
@MainActor public final class EnvironmentValueContainer<T>: ObservableObject {
    /// A value to contain in the environment object.
    public let value: T

    /// Creates a new `EnvironmentValueContainer` instance.
    /// - Parameter value: A value to contain in the environment object.
    public init(value: T) {
        self.value = value
    }
}
