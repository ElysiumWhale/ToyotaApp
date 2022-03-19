import Foundation

/// Keys for information **pushing to** and **retrieving from**  `UserDefaults`
enum DefaultKeys: String {
    case noCarsMessage
    case selectedCity
    case selectedShowroom
}

public class DefaultsManager {
    private static let defaults = UserDefaults.standard

    class func getUserInfo<T: Codable>(for key: DefaultKeys) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    @discardableResult
    class func push<T: Codable>(info: T, for key: DefaultKeys) -> Bool {
        do {
            let data = try JSONEncoder().encode(info)
            defaults.set(data, forKey: key.rawValue)
            return true
        } catch let decodeError as NSError {
            assertionFailure("Encoder error: \(decodeError.localizedDescription)")
            return false
        }
    }

    class func clearAll() {
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        defaults.synchronize()
    }
}

extension Bool {
    static var noCarsMessageIsShown: Self {
        DefaultsManager.getUserInfo(for: .noCarsMessage) ?? false
    }

    static var cityIsSelected: Self {
        let city: City? = DefaultsManager.getUserInfo(for: .selectedCity)
        return city != nil
    }
}

// MARK: - DefaultsBacked
@propertyWrapper struct DefaultsBacked<T: Codable> {
    let key: DefaultKeys

    var wrappedValue: T? {
        get { DefaultsManager.getUserInfo(for: key) }
        set { DefaultsManager.push(info: newValue, for: key) }
    }
}
