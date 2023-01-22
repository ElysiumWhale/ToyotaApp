import Foundation
import SwiftKeychainWrapper

final class KeychainService {
    static let shared = KeychainService()

    private let wrapper: KeychainWrapper
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        wrapper: KeychainWrapper = .standard,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        self.wrapper = wrapper
        self.encoder = encoder
        self.decoder = decoder
    }

    func removeAll() {
        wrapper.removeAllKeys()
    }
}

// MARK: - KeyedCodableStorage
extension KeychainService: KeyedCodableStorage {
    func get<T: Codable>(key: KeychainKeys) -> T? {
        guard let data = wrapper.data(forKey: key.rawValue) else {
            return nil
        }

        return try? decoder.decode(T.self, from: data)
    }

    func set<T: Codable>(value: T, key: KeychainKeys) {
        if let data = try? encoder.encode(value) {
            wrapper.set(data, forKey: key.rawValue.rawValue)
        }
    }

    func update<T: Codable>(key: KeychainKeys, _ updateAction: (T?) -> T) {
        guard let value: T = get(key: key) else {
            set(value: updateAction(nil), key: key)
            return
        }

        set(value: updateAction(value), key: key)
    }

    func remove(key: KeychainKeys) {
        wrapper.remove(forKey: key.rawValue)
    }

    subscript<T: Codable>(key: KeychainKeys) -> T? {
        get {
            get(key: key)
        }
        set {
            set(value: newValue, key: key)
        }
    }
}

// MARK: - ModeledKeychainService
extension KeychainService: ModelKeyedCodableStorage {
    typealias TKey = KeychainKeys

    func get<T: KeyedCodableModel>() -> T? where T.TKey == KeychainKeys {
        guard let data = wrapper.data(forKey: T.key.rawValue),
              let value = try? decoder.decode(T.self, from: data) else {
            return nil
        }

        return value
    }

    func set<T: KeyedCodableModel>(_ value: T) where T.TKey == KeychainKeys {
        if let data = try? encoder.encode(value) {
            wrapper.set(data, forKey: T.key.rawValue.rawValue)
        }
    }

    func update<T: KeyedCodableModel>(_ updateAction: (T?) -> T) where T.TKey == KeychainKeys {
        if let data = wrapper.data(forKey: T.key.rawValue),
           let value = try? decoder.decode(T.self, from: data) {
            set(updateAction(value))
        } else {
            set(updateAction(nil))
        }
    }

    func remove<T: KeyedCodableModel>(_ type: T.Type) where T.TKey == KeychainKeys {
        wrapper.remove(forKey: type.key.rawValue)
    }
}
