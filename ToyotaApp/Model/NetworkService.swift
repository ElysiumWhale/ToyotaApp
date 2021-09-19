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
            if let response = response as? HTTPURLResponse {
                #if DEBUG
                print("\n", "Request status code: ", response.statusCode, "\n")
                #endif
            }
            if error != nil {
                #warning("todo: switch by error code")
                completion(Result.failure(ErrorResponse(code: NetworkErrors.lostConnection.rawValue, message: AppErrors.connectionLost.rawValue)))
            }
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                print(json ?? "Error while parsing json object")
                
                if let response = try? JSONDecoder().decode(T.self, from: data) {
                    completion(Result.success(response))
                } else if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    completion(Result.failure(errorResponse))
                } else {
                    completion(Result.failure(ErrorResponse(code: NetworkErrors.corruptedData.rawValue,
                                                            message: AppErrors.serverBadResponse.rawValue)))
                }
            }
        }.resume()
    }
    
    func makeSimpleRequest(page: RequestPath, params: [URLQueryItem] = []) {
        session.dataTask(with: buildPostRequest(for: page.rawValue, with: params)).resume()
    }
    
    private func buildPostRequest(for page: String, with params: [URLQueryItem] = []) -> URLRequest {
        var query = mainUrl
        query.path.append(page)
        
        let requestUrl = query.url!
        
        query.queryItems = []
        query.queryItems!.append(contentsOf: params)
        
        let data = query.url!.query
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = RequestType.POST.rawValue
        request.httpBody = Data(data!.utf8)
        
        return request
    }
    
    func buildImageUrl(_ path: String) -> URL? {
        var query = MainURL.buildImageUrl()
        query.path.append(path)
        return query.url
    }
}
