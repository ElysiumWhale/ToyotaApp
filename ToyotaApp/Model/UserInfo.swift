import Foundation

class UserInfo {
    let id: UserId
    private(set) var phone: Phone
    private var secretKey: SecretKey
    private(set) var person: Person
    private(set) var showrooms: Showrooms
    private(set) var cars: Cars
    
    class func build() -> Result<UserInfo, AppErrors> {
        let userId = DefaultsManager.getUserInfo(UserId.self)
        let secretKey = DefaultsManager.getUserInfo(SecretKey.self)
        let userPhone = DefaultsManager.getUserInfo(Phone.self)
        let personInfo = DefaultsManager.getUserInfo(Person.self)
        let showroomsInfo = DefaultsManager.getUserInfo(Showrooms.self)
        
        guard let id = userId, let key = secretKey, let phone = userPhone, let person = personInfo, let showrooms = showroomsInfo else {
            return Result.failure(.notFullProfile)
        }
        var res: UserInfo
        if let cars = DefaultsManager.getUserInfo(Cars.self) {
            res = UserInfo(id, key, phone, person, showrooms, cars)
        } else {
            res = UserInfo(id, key, phone, person, showrooms)
        }
        return Result.success(res)
    }
    
    private init(_ userId: UserId, _ key: SecretKey, _ userPhone: Phone, _ personInfo: Person, _ showroomsInfo: Showrooms, _ carsInfo: Cars) {
        id = userId
        secretKey = key
        phone = userPhone
        person = personInfo
        showrooms = showroomsInfo
        cars = carsInfo
    }
    
    private init(_ userId: UserId, _ key: SecretKey, _ userPhone: Phone, _ personInfo: Person, _ showroomsInfo: Showrooms) {
        id = userId
        secretKey = key
        phone = userPhone
        person = personInfo
        showrooms = showroomsInfo
        cars = Cars(CarsInfo([Car]()))
    }
    
    func add(car: Car, from showroom: Showroom) {
        showrooms.value.append(showroom)
        DefaultsManager.pushUserInfo(info: showrooms)
        cars.value.array.append(car)
        DefaultsManager.pushUserInfo(info: cars)
    }
}

extension UserInfo {
    
}

//MARK: - Default Value Classes
protocol DefaultValue: Codable {
    associatedtype T: Codable
    static var key: DefaultKeys { get }
    var value: T { get set }
}

class UserId: DefaultValue {
    typealias T = String
    
    static var key: DefaultKeys = .userId
    var value: String
    
    init(_ id: String) {
        value = id
    }
}

class SecretKey: DefaultValue {
    typealias T = String
    
    static var key: DefaultKeys = .secretKey
    var value: String
    
    init(_ key: String) {
        value = key
    }
}

class Phone: DefaultValue {
    typealias T = String
    
    static var key: DefaultKeys = .phone
    var value: String
    
    init(_ phone: String) {
        value = phone
    }
}

class Person: DefaultValue {
    typealias T = PersonInfo
    
    static var key: DefaultKeys = .person
    var value: PersonInfo
    
    init(_ person: PersonInfo) {
        value = person
    }
}

class Showrooms: DefaultValue {
    typealias T = [Showroom]
    
    static var key: DefaultKeys = .showrooms
    var value: [Showroom]
    
    init(_ showrooms: [Showroom]) {
        value = showrooms
    }
}

class Cars: DefaultValue {
    typealias T = CarsInfo
    
    static var key: DefaultKeys = .cars
    var value: CarsInfo
    
    init(_ cars: CarsInfo) {
        value = cars
    }
}

//MARK: - Helper Classes
class PersonInfo: Codable {
    var firstName: String
    var lastName: String
    var secondName: String
    var email: String
    var birthday: String
    
    private static let empty = "Empty"
    
    init(firstName: String, lastName: String, secondName: String, email: String, birthday: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.secondName = secondName
        self.email = email
        self.birthday = birthday
    }
    
    class func toDomain(_ profile: Profile) -> PersonInfo {
        return PersonInfo(firstName: profile.firstName ?? empty,
                          lastName: profile.lastName ?? empty,
                          secondName: profile.secondName ?? empty,
                          email: profile.email ?? empty,
                          birthday: profile.birthday ?? empty)
    }
}

class CarsInfo: Codable {
    var chosenCar: Car?
    var array: [Car]
    
    init(_ cars: [Car]) {
        array = cars
        chosenCar = array.first
    }
    
    init(_ cars: [Car], chosen car: Car) {
        array = cars
        chosenCar = car
    }
}

//MARK: - Helper Structs
struct Showroom: Codable {
    let id: String
    let showroomName: String
    let cityName: String
}

struct Car: Codable {
    let id: String
    let showroomId: String
    let brand: String
    let model: String
    let color: String
    let colorSwatch: String
    let colorDescription: String
    let isMetallic: String
    let plate: String
    let vin: String
}
