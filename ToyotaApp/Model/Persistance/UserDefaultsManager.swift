import Foundation

/// Keys for information **pushing to** and **retrieving from**  `UserDefaults`
enum DefaultKeys: String {
    case noCarsMessage
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
    
    class func pushUserInfo<T: WithDefaultKey>(info: T) {
        do {
            let data = try JSONEncoder().encode(info)
            defaults.set(data, forKey: T.key.rawValue)
        } catch let decodeError as NSError {
            fatalError("Decoder error: \(decodeError.localizedDescription)")
        }
    }
    
    class func push<T: Codable>(info: T, for key: DefaultKeys) {
        do {
            let data = try JSONEncoder().encode(info)
            defaults.set(data, forKey: key.rawValue)
        } catch let decodeError as NSError {
            fatalError("Decoder error: \(decodeError.localizedDescription)")
        }
    }

    class func clearAll() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
}

extension Bool {
    static var noCarsMessageIsShown: Self {
        DefaultsManager.getUserInfo(for: .noCarsMessage) ?? false
    }
}
