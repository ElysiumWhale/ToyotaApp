import Foundation

/// Dealer brands identificators for network requests
struct Brand {
    static let Toyota = "1"
    static let ToyotaName = "Toyota"
}

enum RequestType: String {
    case POST
    case GET
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
        #if DEBUG
            res.host = debugHost
        #else
            res.host = host
        #endif

        #if DEBUG
            res.path = debugPath
        #else
            res.path = path
        #endif
        return res
    }

    static func buildImageUrl(isSecure: Bool = false) -> URLComponents {
        var res = URLComponents()
        res.scheme = isSecure ? https : http
        #if DEBUG
            res.host = debugHost
        #else
            res.host = host
        #endif

        #if DEBUG
            res.path = debugImgPath
        #else
            res.path = imgPath
        #endif
        return res
    }
}
