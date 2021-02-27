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
    let registerStatus: Int?
    
    let cities: [City]?
    let showrooms: [DTOShowroom]?
    let cars: [DTOCar]?
    
    private enum CodingKeys: String, CodingKey {
        case result
        case userId = "user_id"
        case secretKey = "secret_key"
        case registerPage = "register_page"
        case registeredUser = "registered_user"
        case registerStatus = "register_status"
        
        case cities
        case showrooms
        case cars
    }
}

public struct RegisteredUser: Codable {
    let profile: Profile?
    let showroom: [DTOShowroom]?
    let car: [DTOCar]?
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
    let error_code: String?
    let message: String?
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
    let showroomName: String
    let cityName: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case showroomName = "showroom_name"
        case cityName = "city_name"
    }
}

extension DTOShowroom {
    func toDomain() -> Showroom {
        Showroom(id: id, showroomName: showroomName, cityName: cityName ?? "Empty")
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
    let vin: String?
    let showroomId: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "car_id"
        case brandName = "car_brand_name"
        case modelName = "car_model_name"
        case colorName = "car_color_name"
        case colorSwatch = "color_swatch"
        case colorDescription = "color_description"
        case isMetallic = "color_metallic"
        case licensePlate = "license_plate"
        case vin = "vin_code"
        case showroomId = "showroom_id"
    }
}

extension DTOCar {
    func toDomain(with vin: String, showroom: String) -> Car {
        return Car(id: id, showroomId: showroom,
                   brand: brandName, model: modelName,
                   color: colorName ?? "Empty",
                   colorSwatch: colorSwatch ?? "Empty",
                   colorDescription: colorDescription ?? "Empty",
                   isMetallic: isMetallic ?? "0",
                   plate: licensePlate ?? "Empty", vin: vin)
    }
    
    func toDomain() -> Car {
        return Car(id: id, showroomId: showroomId ?? "-1",
                   brand: brandName, model: modelName,
                   color: colorName ?? "Empty",
                   colorSwatch: colorSwatch ?? "Empty",
                   colorDescription: colorDescription ?? "Empty",
                   isMetallic: isMetallic ?? "-1",
                   plate: licensePlate ?? "Empty", vin: vin ?? "Empty")
    }
}

//MARK: - CarDidCheck
public struct CarDidCheckResponse: Codable {
    let result: String
    let message: String
    let error_code: String?
    let car: DTOCar?
}

//MARK: - GetServicesTypes
public struct ServicesTypesDidGetResponse: Codable {
    let result: String
    let error_code: String?
    let service_type: [ServiceType]?
}

public struct ServiceType: Codable {
    let id: String
    let service_type_name: String
}

//MARK: - GetServices
public struct ServicesDidGetResponse: Codable {
    let result: String
    let error_code: String?
    let message: String?
    let services: [Service]?
}

public struct Service: Codable {
    let id: String
    let showroomId: String
    let serviceTypeId: String
    let serviceName: String
    let koeffTime: String
    let multiply: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case showroomId = "showroom_id"
        case serviceTypeId = "service_type_id"
        case serviceName = "service_name"
        case koeffTime = "koeff_time"
        case multiply
    }
}

//MARK: - GetFreeTime for Service
public struct FreeTimeDidGetResponse: Codable {
    let result: String
    let errorCode: String?
    let message: String?
    let startDate: String?
    let endDate: String?
    let freeTimeDict: [String:[Int]]?
    
    private enum CodingKeys: String, CodingKey {
        case result
        case errorCode = "error_code"
        case message
        case startDate = "start_date"
        case endDate = "end_date"
        case freeTimeDict = "free_time"
    }
}
