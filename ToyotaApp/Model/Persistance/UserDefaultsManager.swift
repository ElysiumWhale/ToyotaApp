import Foundation

/// Keys for information **pushing to** and **retrieving from**  `UserDefaults`
enum DefaultKeys: String {
    case noCarsMessage
    case selectedCity
    case selectedShowroom
}

public class DefaultsManager {
    class func retrieve<T: Codable>(for key: DefaultKeys,
                                    container: UserDefaults = .standard) -> T? {
        guard let data = container.data(forKey: key.rawValue) else {
            return nil
        }

        return try? JSONDecoder().decode(T.self, from: data)
    }

    @discardableResult
    class func push<T: Codable>(info: T,
                                for key: DefaultKeys,
                                container: UserDefaults = .standard) -> Bool {
        do {
            let data = try JSONEncoder().encode(info)
            container.set(data, forKey: key.rawValue)
            return true
        } catch let decodeError as NSError {
            assertionFailure("Encoder error: \(decodeError.localizedDescription)")
            return false
        }
    }

    class func clearAll(in container: UserDefaults = .standard) {
        container.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        container.synchronize()
    }
}

extension Bool {
    static var noCarsMessageIsShown: Self {
        DefaultsManager.retrieve(for: .noCarsMessage) ?? false
    }

    static var cityIsSelected: Self {
        let city: City? = DefaultsManager.retrieve(for: .selectedCity)
        return city != nil
    }
}

// MARK: - DefaultsBacked
@propertyWrapper struct DefaultsBacked<T: Codable> {
    let key: DefaultKeys
    let container: UserDefaults

    var wrappedValue: T? {
        get { DefaultsManager.retrieve(for: key, container: container) }
        set { DefaultsManager.push(info: newValue, for: key, container: container) }
    }

    init(key: DefaultKeys, container: UserDefaults = .standard) {
        self.key = key
        self.container = container
    }
}
