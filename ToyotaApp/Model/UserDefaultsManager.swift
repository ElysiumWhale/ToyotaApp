import Foundation

enum AppErrors: Error {
    case keyValueDoesNotExist
    case wrongKeyForValue
    case notFullProfile
}

enum DefaultKeys: String {
    case person
    case cars
    case showrooms
    case phone
    case userId
    case secretKey
}

struct DefaultsKeys {
    static let secretKey = "secretKey"
    static let userId = "userId"
    static let brandId = "brandId"
    static let profile = "profile"
    static let userDict = "userDict"
    static let vin = "vinCode"
    
    static let phone = "phone"
    static let isAuth = "isAuth"
    static let isFullAccess = "isFullAccess"
    static let person = "person"
    static let showrooms = "showrooms"
    static let showroom = "showroom"
    static let cars = "cars"
    static let car = "car"
    
    static let chosenCar = "chosenCar"
}

protocol WithDefaultsKey: Codable {
    var key: String { get }
}

public class DefaultsManager {
    private static let defaults = UserDefaults.standard
    
    class func buildUserFromDefaults() -> Result<UserInfo, AppErrors> {
        guard let id = defaults.string(forKey: DefaultsKeys.userId), defaults.bool(forKey: DefaultsKeys.isAuth) else {
            return Result.failure(.keyValueDoesNotExist)
        }
        
        let phoneRes: Result<UserInfo.Phone, AppErrors> = retrieveCustomUserInfo(for: .phone)
        let persRes: Result<UserInfo.PersonInfo, AppErrors> = retrieveCustomUserInfo(for: .person)
        let showRes: Result<UserInfo.Showrooms, AppErrors> = retrieveCustomUserInfo(for: .showrooms)
        let carsRes: Result<UserInfo.Cars, AppErrors> = retrieveCustomUserInfo(for: .cars)
        guard let person = try? persRes.get(), let showrooms = try? showRes.get(), let phone = try? phoneRes.get() else {
            return Result.failure(.notFullProfile)
        }
        var res: UserInfo
        if let cars = try? carsRes.get() {
            res = UserInfo(userId: id, personInfo: person, showroomsList: showrooms, carsList: cars)
        } else {
            res = UserInfo(userId: id, personInfo: person, showroomsList: showrooms)
        }
        res.phone = phone
        return Result.success(res)
    }
    
    class func pushUserInfo<T>(info: T) where T:WithDefaultsKey {
        do {
            #warning("to-do: working with arrays")
            let data = try JSONEncoder().encode(info)
            defaults.set(data, forKey: info.key)
        }
        catch let decodeError as NSError {
            print("Decoder error: \(decodeError.localizedDescription)")
        }
    }
    
    class func pushAdditionalInfo<T>(info: T, for key: String) where T:Codable {
        do {
            #warning("to-do: working with arrays")
            let data = try JSONEncoder().encode(info)
            defaults.set(data, forKey: key)
        }
        catch let decodeError as NSError {
            print("Decoder error: \(decodeError.localizedDescription)")
        }
    }
    
    class func retrieveCustomUserInfo<T>(for key: DefaultKeys) -> Result<T, AppErrors> where T:WithDefaultsKey {
        var mappedKey: String
        
        switch key {
            case .phone:
                mappedKey = DefaultsKeys.phone
            case .cars:
                mappedKey = DefaultsKeys.cars
            case .person:
                mappedKey = DefaultsKeys.person
            case .showrooms:
                mappedKey = DefaultsKeys.showrooms
            case .userId:
                mappedKey = DefaultsKeys.userId
            case .secretKey:
                mappedKey = DefaultsKeys.secretKey
        }
        guard let data = defaults.data(forKey: mappedKey) else { return Result.failure(.keyValueDoesNotExist) }
        
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return Result.success(object)
        }
        catch { return Result.failure(.wrongKeyForValue) }
    }
    
    class func retrieveAdditionalInfo<T:DefaultValue>(_ type: T.Type) -> T? {
        guard let data = defaults.data(forKey: T.key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
