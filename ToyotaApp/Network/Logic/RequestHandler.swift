import Foundation

typealias ParameterClosure<T> = ((T) -> Void)

enum ObservationMode {
    case both
    case onSuccess
    case onFailure
}

class RequestHandler<T: Codable> {
    private var queue: DispatchQueue?
    private var mode: ObservationMode = .both

    private var currentTask: URLSessionDataTask? {
        willSet {
            currentTask?.cancel()
        }
    }

    private var onSuccess: ParameterClosure<T>?
    private var onFailure: ParameterClosure<ErrorResponse>?

    func start(with task: URLSessionDataTask) {
        currentTask = task
        currentTask?.resume()
    }

    func invokeSuccess(_ response: T) {
        guard let queue = queue, mode != .onFailure else {
            onSuccess?(response)
            return
        }

        queue.async {
            self.onSuccess?(response)
        }
    }

    func invokeFailure(_ error: ErrorResponse) {
        guard let queue = queue, mode != .onSuccess else {
            onFailure?(error)
            return
        }

        queue.async {
            self.onFailure?(error)
        }
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

    @discardableResult
    func observe(on queue: DispatchQueue, mode: ObservationMode = .both) -> Self {
        self.queue = queue
        self.mode = mode
        return self
    }
}
