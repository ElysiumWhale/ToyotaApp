import Foundation

enum AppErrors: Error {
    case keyValueDoesNotExist
    case wrongKeyForValue
    case notFullProfile
}

enum DefaultKeys: String {
    case phone
    case userId
    case secretKey
    case person
    case cars
    case showrooms
    
}

struct DefaultsKeys {
    static let brandId = "brandId"
    static let vin = "vinCode"
}

public class DefaultsManager {
    private static let defaults = UserDefaults.standard
    
    class func getUserInfo<T:DefaultValue>(_ type: T.Type) -> T? {
        guard let data = defaults.data(forKey: T.key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    class func pushUserInfo<T:DefaultValue>(info: T) {
        do {
            let data = try JSONEncoder().encode(info)
            defaults.set(data, forKey: T.key.rawValue)
        }
        catch let decodeError as NSError {
            fatalError("Decoder error: \(decodeError.localizedDescription)")
        }
    }
}
