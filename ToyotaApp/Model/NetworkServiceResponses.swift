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
    let result: String
    let cities: [City]
}

public struct CityDidChoseResponce: Codable {
    let result: String
    let dealers: [Dealer]
}

public struct DealerDidChoseResponce: Codable {
    let result: String
    let cars: [Car]
}
