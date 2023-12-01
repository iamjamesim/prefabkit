import Combine
import Foundation
import PrefabAppCoreInterface

/// A view model that observes an item collections list.
@MainActor
final class ItemCollectionsViewModel: ObservableObject {
    /// An enum that represents the condition used to determine whether the item collections is empty.
    enum EmptyStateCondition {
        case allCollectionsEmpty
        case collectionsArrayEmpty
    }

    @Published private var pageContent: PageContent
    /// The item collections.
    var collections: [ItemCollectionSubject] {
        pageContent.collections
    }

    /// A Boolean value that indicates whether all item collections are empty.
    @Published private var areAllCollectionsEmpty: Bool

    /// A Boolean value that indicates whether the item collections is empty.
    var isEmpty: Bool {
        switch emptyStateCondition {
        case .allCollectionsEmpty:
            return areAllCollectionsEmpty
        case .collectionsArrayEmpty:
            return collections.isEmpty
        }
    }

    private let pageContentSubject: PageContentSubject
    private let emptyStateCondition: EmptyStateCondition
    private var pageContentCancellable: AnyCancellable?
    private var collectionsCancellables = Set<AnyCancellable>()

    /// Creates a new `ItemCollectionsViewModel` instance.
    /// - Parameter pageContentSubject: A page content subject.
    /// - Parameter emptyStateCondition: An `EmptyStateCondition`.
    init(pageContentSubject: PageContentSubject, emptyStateCondition: EmptyStateCondition) {
        self.pageContentSubject = pageContentSubject
        self.emptyStateCondition = emptyStateCondition
        pageContent = pageContentSubject.value
        areAllCollectionsEmpty = pageContentSubject.value.areAllCollectionsEmpty

        pageContentCancellable = pageContentSubject.receive(on: DispatchQueue.main).sink { [weak self] pageContent in
            self?.onReceive(pageContent: pageContent)
        }
    }

    private func onReceive(pageContent: PageContent) {
        self.pageContent = pageContent
        setIsEmpty()

        collectionsCancellables.removeAll()
        for collection in pageContent.collections {
            collection.receive(on: DispatchQueue.main).sink { [weak self] collection in
                self?.setIsEmpty()
            }
            .store(in: &collectionsCancellables)
        }
    }

    private func setIsEmpty() {
        areAllCollectionsEmpty = pageContent.areAllCollectionsEmpty
    }
}

extension PageContent {
    fileprivate var areAllCollectionsEmpty: Bool {
        for collection in collections {
            if !collection.value.items.isEmpty {
                return false
            }
        }
        return true
    }
}
