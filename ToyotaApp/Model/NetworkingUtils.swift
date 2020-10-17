import Foundation

struct PostRequests {
    static let phoneNumber = "register_phone.php"
    static let smsCode = "check_code.php"
    static let profile = "set_profile.php"
}

struct PostRequestsKeys {
    static let phoneNumber = "phone_number"
    static let code = "code"
}

struct DefaultsKeys {
    static let authKey = "authKey"
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
