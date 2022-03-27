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

enum UrlFactory {
    fileprivate static let https = "https"

    private static let host = "auto.apmobile.ru"
    private static let debugHost = "cv39623.tmweb.ru"

    private static let path = "/mobile/"
    private static let debugPath = "/avtosalon/mobile/"

    private static let imgPath = "/"
    private static let debugImgPath = "/avtosalon/"

    static var mainUrl: URLComponents {
        #if DEBUG
        URLComponents(host: debugHost, path: debugPath)
        #else
        URLComponents(host: host, path: path)
        #endif
    }

    static var imageUrl: URLComponents {
        #if DEBUG
        URLComponents(host: debugHost, path: debugImgPath)
        #else
        URLComponents(host: host, path: imgPath)
        #endif
    }
}

private extension URLComponents {
    init(scheme: String = UrlFactory.https, host: String, path: String) {
        self.init()

        self.scheme = scheme
        self.host = host
        self.path = path
    }
}
