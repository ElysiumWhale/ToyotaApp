import Foundation

///Dealer brands identificators for network requests
struct Brand {
    static let Toyota = "1"
}

struct RequestType {
    static let POST = "POST"
    static let GET = "GET"
}

struct RequestPath {
    struct Start {
        static let checkUser = "check_user.php"
    }
    
    struct Registration {
        static let registerPhone = "register_phone.php"
        static let checkCode = "check_code.php"
        static let setProfile = "set_profile.php"
        static let getShowrooms = "get_showrooms.php"
        static let setShowroom = "set_showroom.php"
        static let checkCar = "check_car.php"
        static let checkVin = "check_vin_code.php"
        static let deleteTemp = "delete_tmp_record.php"
    }
    
    struct Services {
        static let getServicesTypes = "get_service_type.php"
        static let getServices = "get_services.php"
        static let getFreeTime = "get_free_time.php"
        static let bookService = "book_service.php"
        static let getTestDriveCars = "get_cars_ftd.php"
        static let getTestDriveShowrooms = "get_showrooms_list_ftd.php"
        static let getTestDriveServiceId = "get_service_id.php"
    }
    
    struct Profile {
        static let getCities = "get_cities.php"
        static let addShowroom = "add_showroom.php"
        static let editProfile = "edit_profile.php"
        static let getManagers = "get_managers.php"
    }
    
    struct Settings {
        static let changePhone = "change_phone_number.php"
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
        static let sId = "sid"
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
