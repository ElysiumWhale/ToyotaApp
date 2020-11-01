import Foundation

struct Brand {
    static let id = 1 //Toyota
}

struct DebugUserId {
    static var userId: String = ""
}

struct RequestType {
    static let POST = "POST"
}

struct PostRequestPath {
    static let phoneNumber = "register_phone.php"
    static let smsCode = "check_code.php"
    static let profile = "set_profile.php"
    static let getShowrooms = "get_showrooms.php"
}

struct PostRequestKeys {
    static let phoneNumber = "phone_number"
    static let code = "code"
    static let brand_id = "brand_id"
    static let user_id = "user_id"
    static let first_name = "first_name"
    static let second_name = "second_name"
    static let last_name = "last_name"
    static let birthday = "birthday"
    static let email = "email"
    static let city_id = "city_id"
}

struct DefaultsKeys {
    static let authKey = "authKey"
    static let userId = "userId"
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
