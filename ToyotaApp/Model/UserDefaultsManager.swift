import Foundation

enum AppErrors: Error {
    case keyValueDoesNotExist
    case wrongKeyForValue
    case notFullProfile
}

enum DefaultKeys {
    case person
    case cars
    case showrooms
    case phone
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
        
        #warning("to-do phone init")
        //let phoneNum = defaults.string(forKey: DefaultsKeys.phone)
        
        let persRes: Result<UserInfo.PersonInfo, AppErrors> = retrieveUserInfo(for: .person)
        let showRes: Result<UserInfo.Showrooms, AppErrors> = retrieveUserInfo(for: .showrooms)
        let carsRes: Result<UserInfo.Cars, AppErrors> = retrieveUserInfo(for: .cars)
        guard let person = try? persRes.get(), let showrooms = try? showRes.get(), let cars = try? carsRes.get() else {
            //return Result.success(UserInfo(userId: id))
            return Result.failure(.notFullProfile)
        }
        return Result.success(UserInfo(userId: id, personInfo: person, showroomsList: showrooms, carsList: cars))
    }
    
    class func pushUserInfo<T>(info: T) where T:WithDefaultsKey {
        do {
            let data = try JSONEncoder().encode(info)
            defaults.set(data, forKey: info.key)
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
        }
        guard let data = defaults.data(forKey: mappedKey) else { return Result.failure(.keyValueDoesNotExist) }
        
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            return Result.success(object)
        }
        catch { return Result.failure(.wrongKeyForValue) }
    }
}
