import PrefabAppCoreInterface
import SwiftUI

/// An object responsible for routing from one page to another.
@MainActor
final class PageRouter: ObservableObject {
    /// The current navigation stack.
    @Published var navigationStack: [PushDestination] = []
    /// The currently presented modal, if any.
    @Published var presentedModal: ModalDestination? = nil
    /// The current presented error, if any.
    @Published var presentedError: AlertError?

    /// Pushes a destination onto the navigation stack.
    func pushDestination(_ destination: PushDestination) {
        navigationStack.append(destination)
    }

    /// Presents a destination modally.
    func presentModalDestination(_ destination: ModalDestination) {
        presentedModal = destination
    }

    /// Presents an error.
    func presentError(_ error: AlertError) {
        presentedError = error
    }
}

extension PageRouter {
    /// A struct representing a destination that can be pushed onto the navigation stack.
    struct PushDestination: Hashable {
        /// A destination type.
        let destinationType: DestinationType
        /// A page context object.
        let pageContext: PageContext
    }
}
