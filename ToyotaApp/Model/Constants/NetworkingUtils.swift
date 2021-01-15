import Foundation

struct Brand {
    static let id = "1" //Toyota
}

struct Debug {
    //static var userId: String = ""
    //static var secretKey: String = ""
}

struct RequestType {
    static let POST = "POST"
    static let GET = "GET"
}

struct PostRequestPath {
    static let checkUser = "check_user.php"
    static let registerPhone = "register_phone.php"
    static let checkCode = "check_code.php"
    static let setProfile = "set_profile.php"
    static let getShowrooms = "get_showrooms.php"
    static let setShowroom = "set_showroom.php"
    //static let getCars = "get_cars.php"
    static let checkCar = "check_car.php"
    static let deleteTemp = "delete_tmp_record.php"
    
    static let getServicesTypes = "get_service_type.php"
    static let getServices = "get_services.php"
}

struct PostRequestKeys {
    static let phoneNumber = "phone_number"
    static let secretKey = "secret_key"
    static let code = "code"
    static let brandId = "brand_id"
    static let userId = "user_id"
    static let firstName = "first_name"
    static let secondName = "second_name"
    static let lastName = "last_name"
    static let birthday = "birthday"
    static let email = "email"
    static let cityId = "city_id"
    static let showroomId = "showroom_id"
    static let carId = "car_id"
    static let vinCode = "vin_code"
    static let serviceTypeId = "service_type_id"
    static let skipStep = "skip_step"
}

struct MainURL {
    private static let http = "http"
    private static let https = "https"
    private static let host = "cv39623.tmweb.ru"
    private static let path = "/avtosalon/mobile/"
    
    static func buildHttp() -> URLComponents {
        var res = URLComponents()
        res.scheme = http
        res.host = host
        res.path = path
        return res
    }
    
    static func buildHttps() -> URLComponents {
        var res = URLComponents()
        res.scheme = https
        res.host = host
        res.path = path
        return res
    }
}
