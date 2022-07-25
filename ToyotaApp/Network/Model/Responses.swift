import Foundation

protocol IResponse: Codable { }

// MARK: - Default response
struct SimpleResponse: IResponse {
    let result: String

    private enum CodingKeys: String, CodingKey {
        case result
    }
}

// MARK: - CheckUserOrSmsCodeResponse
struct CheckUserOrSmsCodeResponse: IResponse {
    let result: String
    let secretKey: String
    let userId: String?
    let registerPage: Int?
    let registeredUser: RegisteredUser?
    let registerStatus: Int?

    let cities: [City]?
    let models: [Model]?
    let colors: [Color]?

    private enum CodingKeys: String, CodingKey {
        case result, cities, models, colors
        case secretKey = "secret_key"
        case userId = "user_id"
        case registerPage = "register_page"
        case registeredUser = "registered_user"
        case registerStatus = "register_status"
    }
}

// MARK: - CitiesResponse
struct CitiesResponse: IServiceResponse {
    let result: String
    let cities: [City]
    let models: [Model]?
    let colors: [Color]?

    var array: [IService] { cities }
}

// MARK: - ShowroomsResponse
struct ShowroomsResponse: IResponse {
    let result: String
    let showrooms: [Showroom]
}

// MARK: - ModelsAndColorsResponse
struct ModelsAndColorsResponse: IResponse {
    let result: String
    let models: [Model]
    let colors: [Color]
}

// MARK: - CarSetResponse
struct CarSetResponse: IResponse {
    let result: String
    let carId: String

    private enum CodingKeys: String, CodingKey {
        case result
        case carId = "car_id"
    }
}

// MARK: - ShoroomsResponce
struct ShoroomsResponce: IServiceResponse {
    let result: String
    let showrooms: [Showroom]

    var array: [IService] { showrooms }
}

// MARK: - ServicesTypesResponse
struct ServicesTypesResponse: IResponse {
    let result: String
    let serviceType: [ServiceType]

    private enum CodingKeys: String, CodingKey {
        case result
        case serviceType = "service_type"
    }
}

// MARK: - ServicesResponse
struct ServicesResponse: IServiceResponse {
    let result: String
    let services: [Service]

    var array: [IService] { services }
}

// MARK: - FreeTimeResponse
struct FreeTimeResponse: IResponse {
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
struct ManagersResponse: IResponse {
    let result: String
    let managers: [Manager]
}

// MARK: - CarsResponse
struct CarsResponse: IServiceResponse {
    var array: [IService] { cars }

    let result: String
    let cars: [Service]
}

// MARK: - BookingsResponse
struct BookingsResponse: IResponse {
    let result: String
    let booking: [Booking]
    let count: Int
}
