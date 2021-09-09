import Foundation

/// Dealer brands identificators for network requests
struct Brand {
    static let Toyota = "1"
}

struct RequestType {
    static let POST = "POST"
    static let GET = "GET"
}

enum RequestPath {
    case start(_ page: Start)
    case regisrtation(_ page: Registration)
    case services(_ page: Services)
    case profile(_ page: Profile)
    case setting(_ page: Settings)
    
    var rawValue: String {
        switch self {
            case .start(let page): return page.rawValue
            case .regisrtation(let page): return page.rawValue
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
    }
    
    enum Settings: String {
        case changePhone = "change_phone_number.php"
    }
}

struct RequestKeys {
    struct Auth {
        static let userId = "user_id"
        static let secretKey = "secret_key"
        static let code = "code"
        static let brandId = "brand_id"
    }
    
    struct PersonalInfo {
        static let phoneNumber = "phone_number"
        static let firstName = "first_name"
        static let secondName = "second_name"
        static let lastName = "last_name"
        static let birthday = "birthday"
        static let email = "email"
    }
    
    struct CarInfo {
        static let cityId = "city_id"
        static let showroomId = "showroom_id"
        static let carId = "car_id"
        static let skipStep = "skip_step"
        static let vinCode = "vin_code"
    }
    
    struct Services {
        static let serviceTypeId = "service_type_id"
        static let serviceId = "service_id"
        static let dateBooking = "date_booking"
        static let startBooking = "start_booking"
        static let longitude = "longitude"
        static let latitude = "latitude"
    }
}

struct MainURL {
    private static let http = "http"
    private static let https = "https"
    private static let host = "cv39623.tmweb.ru"
    private static let path = "/avtosalon/mobile/"
    private static let imgPath = "/avtosalon/"
    
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
