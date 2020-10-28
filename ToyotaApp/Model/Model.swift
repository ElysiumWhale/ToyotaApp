import Foundation

public struct Car {
    let model: String
    let year: Int
    let color: String
}

public struct City : Codable {
    let id: String
    let cities: String
}

public struct Dealer : Codable {
    let id: String
    let address: String
}
