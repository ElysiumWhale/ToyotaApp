import Foundation
import SwiftKeychainWrapper

/// Keys for information **pushing to** and **retrieving from**  `Keychain`
enum KeychainKeys: KeychainWrapper.Key {
    case phone
    case userId
    case secretKey
    case person
    case cars
    case showrooms
}

/// Used for classes/structs which need to be stored in `Keychain`
protocol Keychainable: Codable {
    static var key: KeychainKeys { get }
}

/// Utility class for managing data stored in `Keychain`
class KeychainManager<T: Keychainable> {
    class func get() -> T? {
        guard let data = KeychainWrapper.standard.data(forKey: T.key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    class func set(_ info: T) {
        if let data = try? JSONEncoder().encode(info) {
            KeychainWrapper.standard.set(data, forKey: T.key.rawValue.rawValue)
        }
    }
    
    class func update(_ action: (T?) -> T) {
        guard let data = KeychainWrapper.standard.data(forKey: T.key.rawValue),
              let value = try? JSONDecoder().decode(T.self, from: data) else {
            set(action(nil))
            return
        }
        
        set(action(value))
    }
    
    class func clear() {
        KeychainWrapper.standard.remove(forKey: T.key.rawValue)
    }
}

// MARK: - T == UserId for avoiding specifying type
extension KeychainManager where T == UserId {
    static func clearAll() {
        KeychainWrapper.standard.removeAllKeys()
    }
}
