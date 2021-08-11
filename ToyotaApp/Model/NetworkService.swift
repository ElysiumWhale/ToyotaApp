import Foundation

class NetworkService {
    public static let shared: NetworkService = NetworkService()
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    private var mainUrl: URLComponents
    
    private init() {
        #warning("MAKE ME HTTPS!")
        // To turn off delete dictionary AppTransportSecuritySettings in info.plist
        mainUrl = MainURL.build()
    }
    
    func makePostRequest<T>(page: String, params: [URLQueryItem] = [], completion: @escaping (Result<T, ErrorResponse>) -> Void = {_ in }) where T: Codable {
        let request = buildPostRequest(for: page, with: params)
        
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
    
    func makeSimpleRequest(page: String, params: [URLQueryItem] = []) {
        session.dataTask(with: buildPostRequest(for: page, with: params)).resume()
    }
    
    private func buildPostRequest(for page: String, with params: [URLQueryItem] = []) -> URLRequest {
        var query = mainUrl
        query.path.append(page)
        
        let requestUrl = query.url!
        
        query.queryItems = []
        query.queryItems!.append(contentsOf: params)
        
        let data = query.url!.query
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = RequestType.POST
        request.httpBody = Data(data!.utf8)
        
        return request
    }
    
    func buildImageUrl(_ path: String) -> URL? {
        var query = MainURL.buildImageUrl()
        query.path.append(path)
        return query.url
    }
}
