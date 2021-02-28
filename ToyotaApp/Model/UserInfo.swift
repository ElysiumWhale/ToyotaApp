import Foundation

protocol UserProxy {
    static func build() -> Result<UserProxy, AppErrors>
    func update(_ personData: Person)
    func update(_ add: Car, _ from: Showroom)
    func update(_ selected: Car)
    var getPerson: Person { get }
    var getShowrooms: Showrooms { get }
    var getSelectedShowroom: Showroom? { get }
    var getCars: Cars { get }
}

extension UserProxy {
    static func build() -> Result<UserProxy, AppErrors> { UserInfo.buildUser() }
}

class UserInfo {
    let id: UserId
    private var phone: Phone
    private var secretKey: SecretKey
    private var person: Person
    private var showrooms: Showrooms
    private var cars: Cars
    
    fileprivate class func buildUser() -> Result<UserProxy, AppErrors> {
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
    
    //MARK: - Constructors
    private init(_ userId: UserId, _ key: SecretKey, _ userPhone: Phone,
                 _ personInfo: Person, _ showroomsInfo: Showrooms, _ carsInfo: Cars) {
        id = userId
        secretKey = key
        phone = userPhone
        person = personInfo
        showrooms = showroomsInfo
        cars = carsInfo
    }
    
    private init(_ userId: UserId, _ key: SecretKey, _ userPhone: Phone,
                 _ personInfo: Person, _ showroomsInfo: Showrooms) {
        id = userId
        secretKey = key
        phone = userPhone
        person = personInfo
        showrooms = showroomsInfo
        cars = Cars([Car]())
    }
}

//MARK: - UserProxy
extension UserInfo: UserProxy {
    var getPerson: Person { person }
    
    var getSelectedShowroom: Showroom? { showrooms.value.first(where: {$0.id == cars.chosenCar!.showroomId}) }
    
    var getShowrooms: Showrooms { showrooms }
    
    var getCars: Cars { cars }
    
    func update(_ personData: Person) {
        person = personData
        DefaultsManager.pushUserInfo(info: person)
    }
    
    func update(_ add: Car, _ from: Showroom) {
        if showrooms.value.first(where: {$0.id == from.id}) == nil {
            showrooms.value.append(from)
            DefaultsManager.pushUserInfo(info: showrooms)
        }
        cars.array.append(add)
        DefaultsManager.pushUserInfo(info: cars)
    }
    
    func update(_ selected: Car) {
        cars.chosenCar = selected
        DefaultsManager.pushUserInfo(info: cars)
    }
}

//MARK: - Classes with default key
protocol WithDefaultKey: Codable {
    static var key: DefaultKeys { get }
}

class UserId: WithDefaultKey {
    static var key: DefaultKeys = .userId
    var id: String
    
    init(_ value: String) {
        id = value
    }
}

class SecretKey: WithDefaultKey {
    static var key: DefaultKeys = .secretKey
    var secret: String
    
    init(_ key: String) {
        secret = key
    }
}

class Phone: WithDefaultKey {
    static var key: DefaultKeys = .phone
    var phone: String
    
    init(_ number: String) {
        phone = number
    }
}

class Showrooms: WithDefaultKey {
    static var key: DefaultKeys = .showrooms
    var value: [Showroom]
    
    init(_ showrooms: [Showroom]) {
        value = showrooms
    }
}

class Person: WithDefaultKey {
    static var key: DefaultKeys = .person
    
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
    
    class func toDomain(_ profile: Profile) -> Person {
        Person(firstName: profile.firstName ?? empty,
                          lastName: profile.lastName ?? empty,
                          secondName: profile.secondName ?? empty,
                          email: profile.email ?? empty,
                          birthday: profile.birthday ?? empty)
    }
}

class Cars: WithDefaultKey {
    static var key: DefaultKeys = .cars
    
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
