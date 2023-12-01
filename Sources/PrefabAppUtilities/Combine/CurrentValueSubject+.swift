import Combine

extension CurrentValueSubject: Identifiable where Output: Identifiable {
    public var id: Output.ID {
        return value.id
    }
}
