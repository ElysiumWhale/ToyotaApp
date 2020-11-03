import Foundation

//MARK: - PhoneDidSendResponse
public struct PhoneDidSendResponse: Codable {
    let result: Int
    //TODO: let firstTimeFlag: Int
}

//MARK: - SmsCodeDidSendResponse
public struct SmsCodeDidSendResponse: Codable {
    let result: Int
    let user_id: String //TODO: Int
}

//MARK: - ProfileDidSetResponse
public struct ProfileDidSetResponse: Codable {
    let result: String
    let cities: [City]
}

public struct City: Codable {
    let id: String
    let cityName: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case cityName = "city_name"
    }
}

//MARK: - CityDidSelectResponce
public struct CityDidSelectResponce: Codable {
    let result: String
    let dealers: [Dealer]
}

public struct Dealer : Codable {
    let id: String
    let address: String
}

//MARK: - ShowroomDidSelectResponse
public struct ShowroomDidSelectResponse: Codable {
    let result: String
    let cars: [Car]
}

public struct Car : Codable {
    let id: String
    let modelName: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case modelName = "model_name"
    }
}

public struct DealerDidSelectResponce: Codable {
    let result: String
    let cars: [Car]
}
