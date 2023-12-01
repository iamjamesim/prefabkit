import Foundation

/// A protocol for an analytics event logger.
public protocol AnalyticsProtocol {
    /// Logs an error.
    /// - Parameters:
    ///   - error: An error to log.
    func logError(_ error: Error)
}
