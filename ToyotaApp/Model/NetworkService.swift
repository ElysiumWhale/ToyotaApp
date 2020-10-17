import Foundation

class NetworkService {
    
    public static let shared: NetworkService = NetworkService()
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    private var mainUrl: URLComponents
    
    private init() {
        /* MAKE ME HTTPS! To turn off delete dictionary "AppTransportSecuritySettings" in info.plist */
        mainUrl = MainURL.buildHttp()
    }
    
    private var profileId: URLQueryItem {
        return URLQueryItem(name: "id", value: UserDefaults.standard.string(forKey: UserDefaultsKeys.userId))
    }
    
    func makeRequest(with url: URL, completion: @escaping (Data?) -> Void) {
        session.dataTask(with: url) {
            (data, response, error) in
            if data != nil { return completion(data) }
            else { return }
        }.resume()
    }
    
    func makePostRequest(page: String, params: [URLQueryItem] = [], completion: @escaping (Data?)->Void = {_ in }) {
        var request = mainUrl
        request.path.append(page)
        request.queryItems = []
        request.queryItems!.append(profileId)
        request.queryItems!.append(contentsOf: params)
        
        session.dataTask(with: request.url!) { (data, response, error) in
            if let response = response { print(response) }
            if let data = data {
                do {
                    print(try JSONSerialization.jsonObject(with: data, options: []))
                    completion(data)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}
