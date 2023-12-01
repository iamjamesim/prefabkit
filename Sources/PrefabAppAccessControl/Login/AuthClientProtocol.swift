import Foundation

/// A protocol for an authentication client.
public protocol AuthClientProtocol {
    /// A stream of authentication client events.
    ///
    /// The `AuthClient` should send new events whenever authentication state changes occur.
    var eventStream: AsyncStream<AuthClientEvent> { get }

    /// Signs in a user using an email.
    /// - Parameter email: An email.
    func signInWithEmail(_ email: String) async throws

    /// Verifies an email sign-in code.
    /// - Parameters:
    ///   - email: An email.
    ///   - code: A sign-in code.
    func verifySignInWithEmail(email: String, code: String) async throws
}

/// An enum that represents authentication client events.
public enum AuthClientEvent {
    /// User logged in event.
    case loggedIn
    /// User logged out event.
    case loggedOut
}
