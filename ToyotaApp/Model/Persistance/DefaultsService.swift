import Foundation

struct DefaultsContainer {
    let defaults: UserDefaults
    let name: String

    init(name: String = "") {
        self.name = name

        defaults = name.isEmpty
            ? .standard
            : UserDefaults(suiteName: name)!
    }

    static var standard: Self {
        DefaultsContainer()
    }
}

final class DefaultsService: KeyedCodableStorage {
    static let shared = DefaultsService()

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let container: DefaultsContainer

    init(
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init(),
        container: DefaultsContainer = .standard
    ) {
        self.encoder = encoder
        self.decoder = decoder
        self.container = container
    }

    func get<T: Codable>(key: DefaultKeys) -> T? {
        guard let data = container.defaults.data(forKey: key.rawValue) else {
            return nil
        }

        return try? decoder.decode(T.self, from: data)
    }

    func set<T: Codable>(value: T, key: DefaultKeys) {
        if let data = try? encoder.encode(value) {
            container.defaults.set(data, forKey: key.rawValue)
        }
    }

    func update<T: Codable>(key: DefaultKeys, _ updateAction: (T?) -> T) {
        guard let value: T? = get(key: key) else {
            set(value: updateAction(nil), key: key)
            return
        }

        set(value: value, key: key)
    }

    func remove(key: DefaultKeys) {
        container.defaults.removeObject(forKey: key.rawValue)
    }

    func removeAll() {
        container.defaults.removePersistentDomain(forName: container.name)
        container.defaults.synchronize()
    }

    subscript<T: Codable>(key: DefaultKeys) -> T? {
        get {
            get(key: key)
        }
        set {
            set(value: newValue, key: key)
        }
    }
}
