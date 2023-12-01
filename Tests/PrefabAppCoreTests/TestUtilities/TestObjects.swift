import Combine
import Foundation
@testable import PrefabAppCore

struct TestItem: AppObject, Identifiable {
    typealias DTO = TestItemDTO
    static let objectType: AppObjectType = .item

    let id: String
    let title: String
    let body: String

    init(dto: TestItemDTO, relatedObjectProvider: AppObjectProvider) throws {
        id = dto.id
        title = dto.title
        body = dto.body
    }
}

struct TestItemDTO: AppObjectDTO {
    typealias Object = TestItem

    let id: String
    let title: String
    let body: String
}

struct TestItemAuthor: AppObject {
    typealias DTO = TestItemAuthorDTO
    static let objectType: AppObjectType = .userProfile

    let id: String

    init(dto: TestItemAuthorDTO, relatedObjectProvider: AppObjectProvider) throws {
        id = dto.id
    }
}

struct TestItemAuthorDTO: AppObjectDTO {
    typealias Object = TestItemAuthor

    let id: String
    let name: String
}

final class TestNoopObjectProvider: AppObjectProvider {
    struct NotImplemented: Error {}

    func appObject<U>(forID objectID: String) throws -> CurrentValueSubject<U, Never> where U : AppObject {
        throw NotImplemented()
    }
}
