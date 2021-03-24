import Foundation

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
