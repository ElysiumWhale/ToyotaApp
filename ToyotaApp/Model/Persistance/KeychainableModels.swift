import Foundation

struct UserId: Keychainable, Equatable {
    static var key: KeychainKeys { .userId }

    let value: String
}

struct SecretKey: Keychainable, Equatable {
    static var key: KeychainKeys { .secretKey }

    let value: String
}

struct Phone: Keychainable, Equatable {
    static var key: KeychainKeys { .phone }

    let value: String
}

struct Person: Keychainable, Equatable {
    static var key: KeychainKeys { .person }

    let firstName: String
    let lastName: String
    let secondName: String
    let email: String
    let birthday: String

    init(
        firstName: String?,
        lastName: String?,
        secondName: String?,
        email: String?,
        birthday: String?
    ) {
        self.firstName = firstName ?? .empty
        self.lastName = lastName ?? .empty
        self.secondName = secondName ?? .empty
        self.email = email ?? .empty
        self.birthday = birthday ?? .empty
    }
}

struct Cars: Keychainable, Equatable {
    static var key: KeychainKeys { .cars }

    var cars: [Car]
    var defaultCar: Car?

    init(_ cars: [Car], _ selected: Car? = nil) {
        self.cars = cars
        if let selected = selected, cars.contains(selected) {
            self.defaultCar = selected
        } else {
            self.defaultCar = cars.first
        }
    }
}
