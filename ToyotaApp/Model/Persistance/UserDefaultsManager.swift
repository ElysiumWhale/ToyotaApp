import Foundation

/// Keys for information **pushing to** and **retrieving from**  `UserDefaults`
enum DefaultKeys: String {
    case noCarsMessage
    case selectedCity
    case selectedShowroom
}

protocol WithDefaultKey: Codable {
    static var key: DefaultKeys { get }
}

public class DefaultsManager {
    private static let defaults = UserDefaults.standard

    class func getUserInfo<T: WithDefaultKey>(_ type: T.Type) -> T? {
        guard let data = defaults.data(forKey: T.key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    class func getUserInfo<T: Codable>(for key: DefaultKeys) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    @discardableResult
    class func pushUserInfo<T: WithDefaultKey>(info: T?) -> Bool {
        guard let information = info else {
            return false
        }

        do {
            let data = try JSONEncoder().encode(information)
            defaults.set(data, forKey: T.key.rawValue)
            return true
        } catch let decodeError as NSError {
            assertionFailure("Decoder error: \(decodeError.localizedDescription)")
            return false
        }
    }

    @discardableResult
    class func push<T: Codable>(info: T, for key: DefaultKeys) -> Bool {
        do {
            let data = try JSONEncoder().encode(info)
            defaults.set(data, forKey: key.rawValue)
            return true
        } catch let decodeError as NSError {
            assertionFailure("Decoder error: \(decodeError.localizedDescription)")
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
