import Foundation

class NetworkService {
    private static let session = URLSession(configuration: URLSessionConfiguration.default)
    
    private static let mainUrl = MainURL.build(isSecure: true)
    
    class func makePostRequest<T: Codable>(page: RequestPath,
                                           params: RequestItems = .empty,
                                           completion: @escaping (Result<T, ErrorResponse>) -> Void = {_ in }) {
        let request = buildPostRequest(for: page.rawValue, with: params.asQueryItems)
        
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                #warning("todo: switch by error code")
                completion(Result.failure(.lostConnection))
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(Result.failure(.corruptedData))
                }
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data)
            print(json ?? "Error while parsing json object")
            
            if let response = try? JSONDecoder().decode(T.self, from: data) {
                completion(Result.success(response))
            } else if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                completion(Result.failure(errorResponse))
            } else {
                completion(Result.failure(.corruptedData))
            }
        }.resume()
    }
    
    class func makeRequest<T: Codable>(page: RequestPath,
                                       params: RequestItems = .empty,
                                       handler: RequestHandler<T>) {
        let request = buildPostRequest(for: page.rawValue,
                                       with: params.asQueryItems)
        
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                #warning("todo: switch by error code")
                handler.onFailure?(.lostConnection)
                return
            }
            
            guard let data = data else {
                handler.onFailure?(.corruptedData)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data)
            print(json ?? "Error while parsing json object")
            
            if let response = try? JSONDecoder().decode(T.self, from: data) {
                handler.onSuccess?(response)
            } else if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                handler.onFailure?(errorResponse)
            } else {
                handler.onFailure?(.corruptedData)
            }
        }.resume()
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
        var query = MainURL.buildImageUrl()
        query.path.append(path)
        return query.url
    }
}

// MARK: - Request items
typealias RequestItem = (key: RequestKeys, value: String?)
typealias RequestItems = [RequestItem]

extension Array where Element == RequestItem {
    var asQueryItems: [URLQueryItem] {
        map({ key, value in .init(name: key.rawValue, value: value) })
    }
    
    static let empty: RequestItems = []
}
