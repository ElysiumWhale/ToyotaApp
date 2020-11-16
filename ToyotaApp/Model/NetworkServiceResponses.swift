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

//MARK: - CheckUserResponce
public struct CheckUserResponse: Codable {
    let result: String
    let secretKey: String
    let registerPage: Int?
    let registeredUser: RegisteredUser?
    
    let cities: [City]?
    //let showrooms: [Showroom]?
    let cars: [Car]?
    
    private enum CodingKeys: String, CodingKey {
        case result
        case secretKey = "secret_key"
        case registerPage = "register_page"
        case registeredUser = "registered_user"
        
        case cities
        //case showrooms
        case cars
    }
}

public struct RegisteredUser: Codable {
    let profile: Profile?
    let showroom: [Showroom]?
    let car: [Car]?
    
    struct Showroom: Codable {
        let id: String
        let showroomName: String
        let cityName: String
        
        private enum CodingKeys: String, CodingKey {
            case id
            case showroomName = "showroom_name"
            case cityName = "city_name"
        }
    }
}

public struct Profile: Codable {
    let phone: String?
    let firstName: String?
    let lastName: String?
    let secondName: String?
    let email: String?
    let birthday: String?
    
    private enum CodingKeys: String, CodingKey {
        case phone
        case firstName = "first_name"
        case lastName = "last_name"
        case secondName = "second_name"
        case email
        case birthday
    }
}
    
//MARK: - SmsCodeDidSendResponse
public struct SmsCodeDidSendResponse: Codable {
    let result: String
    let userId: String
    let secrectKey: String
    let registerPage: Int?
    let registeredUser: RegisteredUser?
    
    private enum CodingKeys: String, CodingKey {
        case result
        case userId = "user_id"
        case secrectKey = "secret_key"
        case registerPage = "register_page"
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
    let cars: [Car]?
}

public struct Car: Codable {
    let id: String
    let car_brand_name: String
    let car_model_name: String
    let car_color_name: String?
    let color_swatch: String?
    let color_description: String?
    let color_metallic: String?
    let license_plate: String?
}

//MARK: - CarDidCheck
public struct CarDidCheckResponse: Codable {
    let result: String
    let message: String
}
