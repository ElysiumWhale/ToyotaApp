import Foundation

class UserId: Keychainable {
    static var key: KeychainKeys = .userId
    let id: String

    init(_ value: String) {
        id = value
    }
}

class SecretKey: Keychainable {
    static var key: KeychainKeys = .secretKey
    let secret: String

    init(_ key: String) {
        secret = key
    }
}

class Phone: Keychainable {
    static var key: KeychainKeys = .phone
    var phone: String

    init(_ number: String) {
        phone = number
    }
}

class Showrooms: Keychainable {
    static var key: KeychainKeys = .showrooms
    var value: [Showroom]

    init(_ showrooms: [Showroom]) {
        value = showrooms
    }
}

class Person: Keychainable {
    static var key: KeychainKeys = .person

    var firstName: String
    var lastName: String
    var secondName: String
    var email: String
    var birthday: String

    init(firstName: String, lastName: String, secondName: String, email: String, birthday: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.secondName = secondName
        self.email = email
        self.birthday = birthday
    }

    class func toDomain(_ profile: Profile) -> Person {
        Person(firstName: profile.firstName ?? .empty,
               lastName: profile.lastName ?? .empty,
               secondName: profile.secondName ?? .empty,
               email: profile.email ?? .empty,
               birthday: profile.birthday ?? .empty)
    }
}

class Cars: Keychainable {
    static var key: KeychainKeys = .cars

    var defaultCar: Car?
    var array: [Car]

    init(_ cars: [Car]) {
        array = cars
        defaultCar = array.first
    }

    init(_ cars: [Car], chosen car: Car) {
        array = cars
        defaultCar = car
    }
}

// MARK: - Helper Structs
struct Showroom: WithDefaultKey, IService {
    static var key: DefaultKeys { .selectedShowroom }
    var name: String { showroomName }

    let id: String
    let showroomName: String
    let cityName: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case showroomName = "showroom_name"
        case cityName = "city_name"
    }
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
