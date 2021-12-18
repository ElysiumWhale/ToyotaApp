import Foundation

protocol IResponse: Codable {
    
}

// MARK: - Default response
public struct Response: IResponse {
    let result: String

    private enum CodingKeys: String, CodingKey {
        case result
    }
}

// MARK: - CheckUserOrSmsCodeResponse
public struct CheckUserOrSmsCodeResponse: IResponse {
    let result: String
    let secretKey: String
    let userId: String?
    let registerPage: Int?
    let registeredUser: RegisteredUser?
    let registerStatus: Int?

    let cities: [City]?

    private enum CodingKeys: String, CodingKey {
        case result, cities
        case secretKey = "secret_key"
        case userId = "user_id"
        case registerPage = "register_page"
        case registeredUser = "registered_user"
        case registerStatus = "register_status"
    }
}

public struct RegisteredUser: IResponse {
    let profile: Profile
    let cars: [Car]?
}

public struct Profile: IResponse {
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

// MARK: - CitiesResponse
public struct CitiesResponse: IServiceResponse {
    let result: String
    let cities: [City]
    let models: [Model]?
    let colors: [Color]?

    var array: [IService] { cities }
}

public struct City: IService, WithDefaultKey {
    static var key: DefaultKeys = .selectedCity

    let id: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name = "city_name"
    }
}

public struct Model: Codable {
    let id: String
    let name: String
    let brandId: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name = "car_model_name"
        case brandId = "car_brand_id"
    }
}

public struct Color: Codable {
    let id: String
    let name: String
    let code: String
    let colorDescription: String
    let isMetallic: String
    let hex: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name = "car_color_name"
        case code = "color_code"
        case colorDescription = "color_description"
        case isMetallic = "color_metallic"
        case hex = "color_swatch"
    }
}

// MARK: - ModelsAndColorsResponse
public struct ModelsAndColorsResponse: IResponse {
    let result: String
    let models: [Model]
    let colors: [Color]
}

// MARK: - CarSetResponse
public struct CarSetResponse: IResponse {
    let result: String
    let carId: String

    private enum CodingKeys: String, CodingKey {
        case result
        case carId = "car_id"
    }
}

// MARK: - ShoroomsResponce
public struct ShoroomsResponce: IServiceResponse {
    let result: String
    let showrooms: [Showroom]

    var array: [IService] { showrooms }
}

// MARK: - CarCheckResponse
public struct CarCheckResponse: IResponse {
    let result: String
    let message: String // todo: delete message
    // let car: OldCar?
}

// MARK: - ServicesTypesResponse
public struct ServicesTypesResponse: IResponse {
    let result: String
    let serviceType: [ServiceType]

    private enum CodingKeys: String, CodingKey {
        case result
        case serviceType = "service_type"
    }
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

// MARK: - ServicesResponse
public struct ServicesResponse: IServiceResponse {
    let result: String
    let services: [Service]

    var array: [IService] { services }
}

public struct Service: IService {
    let id: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name = "service_name"
    }
}

extension Service {
    static let empty = Service(id: "-1", name: "Нет доступных сервисов")
}

// MARK: - FreeTimeResponse
public struct FreeTimeResponse: IResponse {
    let result: String
    let startDate: String?
    let endDate: String?
    let freeTimeDict: [String: [Int]]?

    private enum CodingKeys: String, CodingKey {
        case result
        case startDate = "start_date"
        case endDate = "end_date"
        case freeTimeDict = "free_times"
    }
}

// MARK: - ManagersResponse
public struct ManagersResponse: IResponse {
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

// MARK: - CarsResponse
public struct CarsResponse: IServiceResponse {
    var array: [IService] { cars }

    let result: String
    let cars: [Service]
}

// MARK: - BookingsResponse
public struct BookingsResponse: IResponse {
    let result: String
    let booking: [Booking]
    let count: Int
}

public struct Booking: Codable {
    let date: String
    let startTime: String
    let latitude: String
    let longitude: String
    let status: BookingStatus
    let carName: String
    let licensePlate: String
    let showroomName: String
    let serviceName: String
    let postName: String

    private enum CodingKeys: String, CodingKey {
        case latitude, longitude, status
        case date = "date_booking"
        case startTime = "booking_start_time"
        case carName = "car_model_name"
        case licensePlate = "license_plate"
        case showroomName = "showroom_name"
        case serviceName = "service_name"
        case postName = "post_name"
    }
}

/// Temporary struct
public struct News {
    let title: String
    let content: String = .empty
    let date: Date = Date()
    let showroomId: String = .empty
    let showroomName: String = .empty
    let imgUrl: URL?
    let url: URL?
}
