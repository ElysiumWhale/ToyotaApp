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
