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

//MARK: - CheckUserResponce & SmsCodeDidSendResponse
public struct CheckUserOrSmsCodeResponse: Codable {
    let result: String
    let userId: String?
    let secretKey: String
    let registerPage: Int?
    let registeredUser: RegisteredUser?
    
    let cities: [City]?
    let showrooms: [DTOShowroom]?
    let cars: [DTOCar]?
    
    private enum CodingKeys: String, CodingKey {
        case result
        case userId = "user_id"
        case secretKey = "secret_key"
        case registerPage = "register_page"
        case registeredUser = "registered_user"
        
        case cities
        case showrooms
        case cars
    }
}

public struct RegisteredUser: Codable {
    let profile: Profile?
    let showroom: [Showroom]?
    let car: [DTOCar]?
    
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
    let showrooms: [DTOShowroom]
}

public struct DTOShowroom: Codable {
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
    let message: String
    let error_code: String?
}

public struct DTOCar: Codable {
    let id: String
    let brandName: String
    let modelName: String
    let colorName: String?
    let colorSwatch: String?
    let colorDescription: String?
    let isMetallic: String?
    let licensePlate: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case brandName = "car_brand_name"
        case modelName = "car_model_name"
        case colorName = "car_color_name"
        case colorSwatch = "color_swatch"
        case colorDescription = "color_description"
        case isMetallic = "color_metallic"
        case licensePlate = "license_plate"
    }
}

extension DTOCar {
    func toDomain(with vin: String) -> Car {
        return Car(id: self.id, brand: self.brandName, model: self.modelName,
                   color: self.colorName ?? "Empty",
                   colorSwatch: self.colorSwatch ?? "Empty",
                   colorDescription: self.colorDescription ?? "Empty",
                   isMetallic: self.isMetallic ?? "0",
                   plate: self.licensePlate ?? "Empty", vin: vin)
    }
}

//MARK: - CarDidCheck
public struct CarDidCheckResponse: Codable {
    let result: String
    let message: String
    let error_code: String?
    let car: DTOCar?
}
