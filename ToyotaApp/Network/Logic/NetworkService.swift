import Foundation

typealias Response<TResponse: IResponse> = Result<TResponse, ErrorResponse>
typealias ResponseHandler<TResponse: IResponse> = (Response<TResponse>) -> Void

struct Request {
    let page: RequestPath
    let body: IBody
}

class NetworkService {
    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpCookieStorage?.cookieAcceptPolicy = .never
        let session = URLSession(configuration: config)
        return session
    }()

    class func makeRequest<TResponse>(page: RequestPath,
                                      params: RequestItems = .empty,
                                      completion: @escaping ResponseHandler<TResponse>) where TResponse: IResponse {

        let request = buildPostRequest(for: page.rawValue, with: params.asQueryItems)

        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(Result.failure(.lostConnection))
                return
            }

            guard let data = data else {
                completion(Result.failure(.corruptedData))
                return
            }

            #if DEBUG
            let json = try? JSONSerialization.jsonObject(with: data)
            print(json ?? "Error while parsing json object")
            #endif

            if let response = try? JSONDecoder().decode(TResponse.self, from: data) {
                completion(Result.success(response))
            } else if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                completion(Result.failure(errorResponse))
            } else {
                completion(Result.failure(.corruptedData))
            }
        }

        task.resume()
    }

    class func makeRequest<TResponse>(page: RequestPath,
                                      params: RequestItems = .empty,
                                      handler: RequestHandler<TResponse>) where TResponse: IResponse {

        let request = buildPostRequest(for: page.rawValue, with: params.asQueryItems)

        let task = session.dataTask(with: request) { [weak handler] (data, response, error) in
            guard error == nil else {
                handler?.invokeFailure(.lostConnection)
                return
            }

            guard let data = data else {
                handler?.invokeFailure(.corruptedData)
                return
            }

            #if DEBUG
            let json = try? JSONSerialization.jsonObject(with: data)
            print(json ?? "Error while parsing json object")
            #endif

            let decoder = JSONDecoder()
            if let response = try? decoder.decode(TResponse.self, from: data) {
                handler?.invokeSuccess(response)
            } else if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                handler?.invokeFailure(errorResponse)
            } else {
                handler?.invokeFailure(.corruptedData)
            }
        }

        handler.start(with: task)
    }

    class func makeRequest<Response>(_ request: Request,
                                     handler: RequestHandler<Response>) where Response: IResponse {
        let request = buildPostRequest(for: request.page.rawValue, with: request.body.asRequestItems)

        let task = session.dataTask(with: request) { [weak handler] (data, response, error) in
            guard error == nil else {
                handler?.invokeFailure(.lostConnection)
                return
            }

            guard let data = data else {
                handler?.invokeFailure(.corruptedData)
                return
            }

            #if DEBUG
            let json = try? JSONSerialization.jsonObject(with: data)
            print(json ?? "Error while parsing json object")
            #endif

            let decoder = JSONDecoder()
            if let response = try? decoder.decode(Response.self, from: data) {
                handler?.invokeSuccess(response)
            } else if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                handler?.invokeFailure(errorResponse)
            } else {
                handler?.invokeFailure(.corruptedData)
            }
        }

        handler.start(with: task)
    }

    class func makeRequest(_ request: Request) {
        session.dataTask(with: buildPostRequest(for: request.page.rawValue,
                                                with: request.body.asRequestItems)).resume()
    }

    class private func buildPostRequest(for page: String,
                                        with params: [URLQueryItem] = []) -> URLRequest {
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
        //                                        options: JSONSerialization.WritingOptions.prettyPrinted)
        // request.httpBody = data
        request.httpBody = Data(mainURL.url!.query!.utf8)
        return request
    }

    class func buildImageUrl(_ path: String) -> URL? {
        var query = UrlFactory.imageUrl
        query.path.append(path)
        return query.url
    }
}

extension URLSessionDataTask: RequestTask { }

// MARK: - Request items
typealias RequestItem = (key: RequestKeys, value: String?)
typealias RequestItems = [RequestItem]

extension Array where Element == RequestItem {
    var asQueryItems: [URLQueryItem] {
        map { key, value in .init(name: key.rawValue, value: value) }
    }

    static let empty: RequestItems = []
}
