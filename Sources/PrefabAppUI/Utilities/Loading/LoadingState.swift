import Foundation

/// An enum that represents the states of a data loading operation.
enum LoadingState<Data> {
    /// The loading state.
    case loading
    /// The loading error state.
    case error
    /// The loaded state.
    case loaded(Data)

    var isError: Bool {
        if case .error = self {
            return true
        } else {
            return false
        }
    }
}
