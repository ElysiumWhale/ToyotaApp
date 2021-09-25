import Foundation

class RequestHandler<T: Codable> {
    var onSuccess: ((T) -> Void)?
    var onFailure: ((ErrorResponse) -> Void)?
    
    func didRecieve(response: Result<T, ErrorResponse>) {
        switch response {
            case .success(let data): onSuccess?(data)
            case .failure(let error): onFailure?(error)
        }
    }
}
