import Foundation

final class UserId: Keychainable {
    static var key: KeychainKeys = .userId
    let value: String

    init(_ value: String) {
        self.value = value
    }
}

final class SecretKey: Keychainable {
    static var key: KeychainKeys = .secretKey
    let value: String

    init(_ key: String) {
        value = key
    }
}

final class Phone: Keychainable {
    static var key: KeychainKeys = .phone
    var value: String

    init(_ number: String) {
        value = number
    }
}

final class Person: Keychainable {
    static var key: KeychainKeys = .person

    var firstName: String
    var lastName: String
    var secondName: String
    var email: String
    var birthday: String

    init(firstName: String?,
         lastName: String?,
         secondName: String?,
         email: String?,
         birthday: String?) {

        self.firstName = firstName ?? .empty
        self.lastName = lastName ?? .empty
        self.secondName = secondName ?? .empty
        self.email = email ?? .empty
        self.birthday = birthday ?? .empty
    }
}

final class Cars: Keychainable {
    static var key: KeychainKeys = .cars

    var defaultCar: Car?
    var value: [Car]

    init(_ cars: [Car]) {
        value = cars
        defaultCar = value.first
    }
}
