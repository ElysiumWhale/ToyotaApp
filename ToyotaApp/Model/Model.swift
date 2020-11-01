import Foundation

public struct Car: Codable {
    let id: String
    let car_name: String
}

public struct City : Codable {
    let id: String
    let city_name: String
}

public struct Dealer : Codable {
    let id: String
    let address: String
}

public struct Profile : Codable {
    var firstName: String
    var secondName: String
    var lastName: String
    var email: String
    var birth: String
}
