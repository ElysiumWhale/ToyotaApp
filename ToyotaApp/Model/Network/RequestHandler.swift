import Foundation

typealias ParameterClosure<T> = ((T) -> Void)

class RequestHandler<T: Codable> {
    private var currentTask: URLSessionDataTask? {
        willSet {
            currentTask?.cancel()
        }
    }

    var onSuccess: ParameterClosure<T>?
    var onFailure: ParameterClosure<ErrorResponse>?
    
    func start(with task: URLSessionDataTask) {
        currentTask = task
        currentTask?.resume()
    }
    
    func didRecieve(response: Result<T, ErrorResponse>) {
        switch response {
            case .success(let data): onSuccess?(data)
            case .failure(let error): onFailure?(error)
        }
        currentTask = nil
    }
    
    deinit {
        currentTask?.cancel()
    }
}
