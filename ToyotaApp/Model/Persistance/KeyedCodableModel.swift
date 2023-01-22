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

protocol KeyedCodableModel<TKey>: Codable {
    associatedtype TKey: Hashable

    static var key: TKey { get }
}

/// Used for classes/structs which need to be stored in `Keychain`
protocol Keychainable: KeyedCodableModel<KeychainKeys> { }
