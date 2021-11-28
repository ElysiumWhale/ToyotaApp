import Foundation

enum RequestKeys {
    case auth(_ key: Auth)
    case personalInfo(_ key: PersonalInfo)
    case carInfo(_ key: CarInfo)
    case services(_ key: Services)
    
    var rawValue: String {
        switch self {
            case .auth(let key): return key.rawValue
            case .personalInfo(let key): return key.rawValue
            case .carInfo(let key): return key.rawValue
            case .services(let key): return key.rawValue
        }
    }
    
    enum Auth: String {
        case userId = "user_id"
        case secretKey = "secret_key"
        case code = "code"
        case brandId = "brand_id"
    }
    
    enum PersonalInfo: String {
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case secondName = "second_name"
        case lastName = "last_name"
        case birthday = "birthday"
        case email = "email"
    }
    
    enum CarInfo: String {
        case cityId = "city_id"
        case showroomId = "showroom_id"
        case carId = "car_id"
        case skipStep = "skip_step"
        case vinCode = "vin_code"
    }
    
    enum Services: String {
        case serviceTypeId = "service_type_id"
        case serviceId = "service_id"
        case dateBooking = "date_booking"
        case startBooking = "start_booking"
        case longitude = "longitude"
        case latitude = "latitude"
    }
}
