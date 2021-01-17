import Foundation

class NetworkService {
    
    public static let shared: NetworkService = NetworkService()
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    private var mainUrl: URLComponents
    
    private init() {
        #warning("MAKE ME HTTPS!")
        //To turn off delete dictionary AppTransportSecuritySettings in info.plist
        mainUrl = MainURL.buildHttp()
    }
    
    private var profileId: URLQueryItem {
        return URLQueryItem(name: RequestKeys.Auth.userId, value: UserDefaults.standard.string(forKey: DefaultsKeys.userId))
    }
    
    func makePostRequest<T>(page: String, params: [URLQueryItem] = [], completion: @escaping (T?)->Void = {_ in }) where T:Codable {
        let request = buildPostRequest(for: page, with: params)
        
        session.dataTask(with: request) { (data, response, error) in
            if let response = response { print(response) }
            if let error = error { print(error) }
            if let data = data {
                do {
                    print(try JSONSerialization.jsonObject(with: data))
                    let response = try JSONDecoder().decode(T.self, from: data)
                    completion(response)
                } catch {
                    print(error.localizedDescription)
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func makeSimplePostRequest(page: String, params: [URLQueryItem] = []) {
        let request = buildPostRequest(for: page, with: params)
        session.dataTask(with: request).resume()
    }
    
    func buildPostRequest(for page: String, with params: [URLQueryItem] = []) -> URLRequest {
        var query = mainUrl
        query.path.append(page)
        
        let requestUrl = query.url!
        
        query.queryItems = []
        query.queryItems!.append(profileId)
        query.queryItems!.append(contentsOf: params)
        
        let data = query.url!.query
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = RequestType.POST
        request.httpBody = Data(data!.utf8)
        
        return request
    }
}
