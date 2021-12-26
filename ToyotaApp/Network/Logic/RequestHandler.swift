import Foundation

typealias ParameterClosure<T> = ((T) -> Void)

class RequestHandler<T: Codable> {
    private var currentTask: URLSessionDataTask? {
        willSet {
            currentTask?.cancel()
        }
    }

    private(set) var onSuccess: ParameterClosure<T>?
    private(set) var onFailure: ParameterClosure<ErrorResponse>?

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

extension RequestHandler {
    @discardableResult
    func bind(onSuccess: ParameterClosure<T>? = nil,
              onFailure: ParameterClosure<ErrorResponse>? = nil) -> Self {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        return self
    }
}
