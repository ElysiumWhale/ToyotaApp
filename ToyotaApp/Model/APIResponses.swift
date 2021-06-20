import Foundation

//MARK: - Default simple response
public struct Response: Codable {
    let result: String
    
    private enum CodingKeys: String, CodingKey {
        case result
    }
}

//MARK: - ErrorResponse
public struct ErrorResponse: Codable, Error {
    let code: String
    let message: String?
    
    private enum CodingKeys: String, CodingKey {
        case code = "error_code"
        case message
    }
}

//MARK: - CheckUserResponce & SmsCodeDidSendResponse
public struct CheckUserOrSmsCodeResponse: Codable {
    let result: String
    let secretKey: String
    let userId: String?
    let registerPage: Int?
    let registeredUser: RegisteredUser?
    let registerStatus: Int?
    
    let cities: [City]?
    let showrooms: [DTOShowroom]?
    let cars: [DTOCar]?
    
    private enum CodingKeys: String, CodingKey {
        case result, cities, showrooms, cars
        case secretKey = "secret_key"
        case userId = "user_id"
        case registerPage = "register_page"
        case registeredUser = "registered_user"
        case registerStatus = "register_status"
    }
}

public struct RegisteredUser: Codable {
    let profile: Profile
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
        case phone, email, birthday
        case firstName = "first_name"
        case lastName = "last_name"
        case secondName = "second_name"
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
    let car: DTOCar?
}

//MARK: - GetServicesTypes
public struct ServicesTypesDidGetResponse: Codable {
    let result: String
    let service_type: [ServiceType]
}

public struct ServiceType: Codable {
    let id: String
    let serviceTypeName: String
    let controlTypeId: String
    let controlTypeDesc: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case serviceTypeName = "service_type_name"
        case controlTypeId = "control_type_id"
        case controlTypeDesc = "control_type_desc"
    }
}

//MARK: - GetServices
public struct ServicesDidGetResponse: Codable {
    let result: String
    let services: [Service]
}

public struct Service: Codable {
    let id: String
    let serviceName: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case serviceName = "service_name"
    }
}

//MARK: - GetFreeTime for Service
public struct FreeTimeDidGetResponse: Codable {
    let result: String
    let startDate: String?
    let endDate: String?
    let freeTimeDict: [String:[Int]]?
    
    private enum CodingKeys: String, CodingKey {
        case result
        case startDate = "start_date"
        case endDate = "end_date"
        case freeTimeDict = "free_times"
    }
}

//MARK: - GetManagers for users showrooms
public struct ManagersDidGetResponse: Codable {
    let result: String
    let managers: [Manager]
}

public struct Manager: Codable {
    let id: String
    let userId: String
    let firstName: String
    let secondName: String
    let lastName: String
    let phone: String
    let email: String
    let imageUrl: String
    let showroomName: String
    
    private enum CodingKeys: String, CodingKey {
        case id, phone, email
        case userId = "user_id"
        case firstName = "first_name"
        case secondName = "second_name"
        case lastName = "last_name"
        case imageUrl = "avatar"
        case showroomName = "showroom_name"
    }
}

//MARK: - MOCK
public struct News {
    let title: String
    let content: String
    let date: Date
    let showroomId: String
    let showroomName: String
    let imgUrl: URL
}
