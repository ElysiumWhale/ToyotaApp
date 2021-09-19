import Foundation

class NetworkService {
    private static let session = URLSession(configuration: URLSessionConfiguration.default)
    
    #warning("MAKE ME HTTPS!")
    private static let mainUrl: URLComponents = MainURL.build()
    
    class func makePostRequest<T: Codable>(page: RequestPath,
                                           params: [URLQueryItem] = [],
                                           completion: @escaping (Result<T, ErrorResponse>) -> Void = {_ in }) {
        let request = buildPostRequest(for: page.rawValue, with: params)
        
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
    
    class func makeSimpleRequest(page: RequestPath, params: [URLQueryItem] = []) {
        session.dataTask(with: buildPostRequest(for: page.rawValue, with: params)).resume()
    }
    
    class private func buildPostRequest(for page: String,
                                        with params: [URLQueryItem] = []) -> URLRequest {
        var mainURL = mainUrl
        mainURL.path.append(page)
        mainURL.queryItems = params
        var request = URLRequest(url: mainURL.url!)
        request.httpBody = Data(mainURL.url!.query!.utf8)
        return request
    }
    
    class func buildImageUrl(_ path: String) -> URL? {
        var query = MainURL.buildImageUrl()
        query.path.append(path)
        return query.url
    }
}
