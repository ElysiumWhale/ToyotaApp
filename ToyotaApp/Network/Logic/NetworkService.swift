import Foundation

typealias NetworkResponse<TResponse> = Result<TResponse, ErrorResponse> where TResponse: IResponse
typealias ResponseCompletion<TResponse> = (NetworkResponse<TResponse>) -> Void where TResponse: IResponse

class NetworkService {
    private static let session = URLSession(configuration: URLSessionConfiguration.default)

    private static let mainUrl = MainURL.build(isSecure: true)

    class func makeRequest<TResponse>(page: RequestPath,
                                      params: RequestItems = .empty,
                                      completion: @escaping ResponseCompletion<TResponse>) where TResponse: IResponse {

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
    
    class func makeRequest(page: RequestPath, params: RequestItems = .empty) {
        session.dataTask(with: buildPostRequest(for: page.rawValue, with: params.asQueryItems)).resume()
    }

    class private func buildPostRequest(for page: String,
                                        with params: [URLQueryItem] = []) -> URLRequest {
        var mainURL = mainUrl
        mainURL.path.append(page)
        mainURL.queryItems = params
        var request = URLRequest(url: mainURL.url!)
        request.httpMethod = RequestType.POST.rawValue
        request.httpBody = Data(mainURL.url!.query!.utf8)
        return request
    }

    class func buildImageUrl(_ path: String) -> URL? {
        var query = MainURL.buildImageUrl(isSecure: true)
        query.path.append(path)
        return query.url
    }
}

// MARK: - Request items
typealias RequestItem = (key: RequestKeys, value: String?)
typealias RequestItems = [RequestItem]

extension Array where Element == RequestItem {
    var asQueryItems: [URLQueryItem] {
        map { key, value in .init(name: key.rawValue, value: value) }
    }

    static let empty: RequestItems = []
}
