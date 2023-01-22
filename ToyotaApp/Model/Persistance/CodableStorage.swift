import Foundation

protocol KeyedCodableStorage<TKey>: AnyObject {
    associatedtype TKey: Hashable

    func get<T: Codable>(key: TKey) -> T?
    func set<T: Codable>(value: T, key: TKey)
    func update<T: Codable>(key: TKey, _ updateAction: (T?) -> T)
    func remove(key: TKey)

    func removeAll()

    subscript<T: Codable>(key: TKey) -> T? { get set }
}

protocol ModelKeyedCodableStorage<TKey>: AnyObject {
    associatedtype TKey: Hashable

    func get<T: KeyedCodableModel>() -> T? where T.TKey == TKey
    func set<T: KeyedCodableModel>(_ value: T) where T.TKey == TKey
    func update<T: KeyedCodableModel>(_ updateAction: (T?) -> T) where T.TKey == TKey
    func remove<T: KeyedCodableModel>(_ type: T.Type) where T.TKey == TKey

    func removeAll()
}
