import Foundation

/// Dealer brands identificators for network requests
struct Brand {
    static let Toyota = "1"
}

enum RequestType: String {
    case POST
    case GET
}

enum RequestPath {
    case start(_ page: Start)
    case registration(_ page: Registration)
    case services(_ page: Services)
    case profile(_ page: Profile)
    case setting(_ page: Settings)
    
    var rawValue: String {
        switch self {
            case .start(let page): return page.rawValue
            case .registration(let page): return page.rawValue
            case .services(let page): return page.rawValue
            case .profile(let page): return page.rawValue
            case .setting(let page): return page.rawValue
        }
    }
    
    enum Start: String {
        case checkUser = "check_user.php"
    }
    
    enum Registration: String {
        case registerPhone = "register_phone.php"
        case checkCode = "check_code.php"
        case setProfile = "set_profile.php"
        case getShowrooms = "get_showrooms.php"
        case setShowroom = "set_showroom.php"
        case checkCar = "check_car.php"
        case checkVin = "check_vin_code.php"
        case deleteTemp = "delete_tmp_record.php"
    }
    
    enum Services: String {
        case getServicesTypes = "get_service_type.php"
        case getServices = "get_services.php"
        case getFreeTime = "get_free_time.php"
        case bookService = "book_service.php"
        case getTestDriveCars = "get_cars_ftd.php"
        case getTestDriveShowrooms = "get_showrooms_list_ftd.php"
        case getTestDriveServiceId = "get_service_id.php"
    }
    
    enum Profile: String {
        case getCities = "get_cities.php"
        case addShowroom = "add_showroom.php"
        case editProfile = "edit_profile.php"
        case getManagers = "get_managers.php"
        case getBookings = "get_users_booking.php"
        case removeCar = "delete_user_car.php"
    }
    
    enum Settings: String {
        case changePhone = "change_phone_number.php"
    }
}

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

enum MainURL {
    private static let http = "http"
    private static let https = "https"

    private static let host = "auto.apmobile.ru"
    private static let debugHost = "cv39623.tmweb.ru"

    private static let path = "/mobile/"
    private static let debugPath = "/avtosalon/mobile/"

    private static let imgPath = "/"
    private static let debugImgPath = "/avtosalon/"

    static func build(isSecure: Bool = false) -> URLComponents {
        var res = URLComponents()
        res.scheme = isSecure ? https : http
        res.host = host
        res.path = path
        return res
    }

    static func buildImageUrl(isSecure: Bool = false) -> URLComponents {
        var res = URLComponents()
        res.scheme = isSecure ? https : http
        res.host = host
        res.path = imgPath
        return res
    }
}
