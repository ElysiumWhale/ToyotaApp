import Foundation

struct UserInfo {
    let id: String
    var phone: String?
    var secretKey = ""
    var isAuthorized: Bool = false
    var isFullAccess: Bool = false
    
    var person: PersonInfo = PersonInfo()
    var cars: [Car] = [Car]()
    var showrooms: [Showroom] = [Showroom]()
    
    struct PersonInfo {
        var firstName: String?
        var lastName: String?
        var secondName: String?
        var email: String?
        var birthday: String?
        
        static func toDomain(profile: Profile) -> PersonInfo {
            return PersonInfo(firstName: profile.firstName, lastName: profile.lastName, secondName: profile.secondName, email: profile.email, birthday: profile.birthday)
        }
    }
    
    struct Showroom {
        let id: String
        let showroomName: String
        let cityName: String
    }
    
    struct Car {
        let id: String
        let brand: String
        let model: String
        let color: String
        let colorSwatch: String
        let colorDescription: String
        let isMetallic: String
        let plate: String
        let vin: String
    }
    
    init(userId: String, isAuth: Bool) {
        id = userId
        isAuthorized = isAuth
    }
    
    init(userId: String, isAuth: Bool, isFull: Bool, personInfo: PersonInfo) {
        id = userId
        isAuthorized = isAuth
        isFullAccess = isFull
        person = personInfo
    }
    
    init(userId: String, isAuth: Bool, isFull: Bool, personInfo: PersonInfo, showroomsList: [Showroom]) {
        id = userId
        isAuthorized = isAuth
        isFullAccess = isFull
        person = personInfo
        showrooms = showroomsList
    }
    
    func saveToUserDefaults() {
        #warning("TODO")
    }
    
    static func buildFromDefaults() -> UserInfo? {
        let defaults = UserDefaults.standard
        guard let dict = defaults.dictionary(forKey: DefaultsKeys.userDict) else { return nil }
        let id = dict["id"] as! String
        let isAuth = dict["isAuth"] as! Bool
        var result = UserInfo(userId: id, isAuth: isAuth)
        guard let person = dict["person"] as? PersonInfo else { return result }
        result.person = person
        guard let showrooms = dict["showrooms"] as? [Showroom], !showrooms.isEmpty else { return result }
        result.showrooms = showrooms
        guard let cars = dict["cars"] as? [Car], !cars.isEmpty else { return result }
        result.cars = cars
        return result
    }
}
