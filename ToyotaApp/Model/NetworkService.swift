import Foundation

class NetworkService {
    
    public static let shared: NetworkService = NetworkService()
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    private var mainUrl: URLComponents
    
    init() {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http" //MAKE ME HTTPS
        urlComponents.host = "cv39623.tmweb.ru"
        urlComponents.path = "/avtosalon/mobile/"
        mainUrl = urlComponents
    }
    
    private var profileId: URLQueryItem {
        get {
             URLQueryItem(name: "id", value: UserDefaults.standard.string(forKey: "user_id"))
        }
    }
    
    func makeRequest(with url: URL, completion: @escaping (Data?) -> Void) {
        session.dataTask(with: url) {
            (data, response, error) in
            if data != nil { return completion(data) }
            else { return }
        }.resume()
    }
    
    func makePostRequest(page: PostRequests, params: [URLQueryItem] = []) {
        var request = mainUrl
        request.path.append(page.rawValue)
        request.queryItems = []
        request.queryItems!.append(profileId)
        request.queryItems!.append(contentsOf: params)
        
        session.dataTask(with: request.url!) { (data, response, error) in
            if let response = response { print(response) }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
