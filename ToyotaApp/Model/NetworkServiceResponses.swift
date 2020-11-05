import Foundation

//MARK: - FailureResponse
public struct FailureResponse: Codable {
    let result: String
    let errorCode: String
    let errorMessage: String
    
    private enum CodingKeys: String, CodingKey {
        case result
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }
}

//MARK: - PhoneDidSendResponse
public struct PhoneDidSendResponse: Codable {
    let result: String
    //TODO: let firstTimeFlag: Int
}

//MARK: - SmsCodeDidSendResponse
public struct SmsCodeDidSendResponse: Codable {
    let result: String?
    let userId: String?
    let secrectKey: String?
    let registeredUser: CheckUserResponse?
    
    private enum CodingKeys: String, CodingKey {
        case result
        case userId = "user_id"
        case secrectKey = "secrect_key"
        case registeredUser = "registered_user"
    }
}

//MARK: - ProfileDidSetResponse
public struct ProfileDidSetResponse: Codable {
    let result: String
    let cities: [City]
}

public struct City: Codable {
    let id: String
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name = "city_name"
    }
}

//MARK: - CityDidSelectResponce
public struct CityDidSelectResponce: Codable {
    let result: String
    let showrooms: [Showroom]
}

public struct Showroom : Codable {
    let id: String
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name = "showroom_name"
    }
}

//MARK: - ShowroomDidSelectResponse
public struct ShowroomDidSelectResponse: Codable {
    let result: String
    let cars: [Car]
}

public struct Car: Codable {
    let brand_name: String
    let model_name: String
    let color_name: String?
    let color_swatch: String?
    let color_description: String?
    let color_metallic: String?
    let license_plate: String?
    let vin_code: String?
}

//MARK: - CheckUserResponce
public struct CheckUserResponse: Codable {
    let secret_key: String
    
    let result_profile: String
    let register_page: Int?
    let profile: Profile?
    
    let result_showroom: String?
    let showroom: [Showroom]?
    
    let result_car: String?
    let car: [Car]?
    
    struct Profile: Codable {
        let phone: String?
        let first_name: String?
        let last_name: String?
        let second_name: String?
        let email: String?
        let birthday: String?
    }
    
    struct Showroom: Codable {
        let showroom_name: String
        let city_name: String
    }
}
