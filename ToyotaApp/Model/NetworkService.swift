import Foundation

class NetworkService {
    public static let shared: NetworkService = NetworkService()
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    private let mainUrl = URL(string: "http://cv39623.tmweb.ru/avtosalon/mobile/")
    private let profileId = URLQueryItem(name: "id", value: "")
    
    func makeRequest(with url: URL, completion: @escaping (Data?) -> Void) {
        session.dataTask(with: url) {
            (data, response, error) in
            if data != nil { return completion(data) }
            else { return }
        }.resume()
    }
    
    func makePostRequest(page: PostRequests, params: [URLQueryItem] = []) {
        var url = mainUrl
        url?.appendPathComponent(page.rawValue)
        var request: URLComponents = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
        for par in params {
            request.queryItems?.append(par)
        }
        
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
