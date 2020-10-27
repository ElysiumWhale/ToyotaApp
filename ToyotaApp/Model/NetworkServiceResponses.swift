import Foundation

public struct PhoneDidSendResponse: Codable {
    let result: Int
    //TODO: let firstTimeFlag: Int
}

public struct SmsCodeDidSendResponse: Codable {
    let result: Int
    let user_id: String //TODO: Int
}

public struct ProfileDidSetResponse: Codable {
    let cities: [City]
    struct City : Codable {
        let id: String
        let cities: String
    }
}
