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
public class KeychainManager {
    private static let wrapper = KeychainWrapper.standard
    
    class func get<T: Keychainable>(_ type: T.Type) -> T? {
        guard let data = wrapper.data(forKey: type.key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    class func set<T: Keychainable>(_ info: T) {
        if let data = try? JSONEncoder().encode(info) {
            wrapper.set(data, forKey: T.key.rawValue.rawValue)
        }
    }
    
    class func update<T: Keychainable>(_ type: T.Type, update: (T?) -> T) {
        guard let data = wrapper.data(forKey: type.key.rawValue),
              let value = try? JSONDecoder().decode(T.self, from: data) else {
            set(update(nil))
            return
        }
        
        set(update(value))
    }
    
    class func clear<T: Keychainable>(_ type: T.Type) {
        wrapper.remove(forKey: type.key.rawValue)
    }
    
    class func clearAll() {
        wrapper.removeAllKeys()
    }
}
