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

    static func makeImageUrl(_ path: String) -> URL? {
        guard path.isNotEmpty else {
            return nil
        }

        var query = UrlFactory.imageUrl
        query.path.append(path)
        return query.url
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

enum RequestFactory {
    static func make(
        for page: String,
        with params: [URLQueryItem] = []
    ) -> URLRequest {
        var mainURL = UrlFactory.mainUrl
        mainURL.path.append(page)
        mainURL.queryItems = params
        var request = URLRequest(url: mainURL.url!)
        request.httpMethod = RequestType.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // MARK: - Future
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // let paramsDict = Dictionary(uniqueKeysWithValues: params.map { ($0.name, $0.value) })
        // let data = try? JSONSerialization.data(withJSONObject: paramsDict,
        //                                        options: JSONSerialisation.WritingOptions.prettyPrinted)
        // request.httpBody = data
        request.httpBody = Data(mainURL.url!.query!.utf8)
        return request
    }
}
