import Combine
import Foundation

/// An `ObservableObject` that can be used to bind a `CurrentValueSubject` to a view.
@MainActor
final class ObservableSubject<T>: ObservableObject {
    /// The current value of the subject.
    @Published private(set) var value: T

    private let subject: CurrentValueSubject<T, Never>

    /// Creates a new `ObservableSubject` instance.
    /// - Parameter subject: A subject to observe.
    init(subject: CurrentValueSubject<T, Never>) {
        self.subject = subject
        value = subject.value
        subject.receive(on: DispatchQueue.main).assign(to: &$value)
    }
}
