import Foundation

typealias DefaultRequestHandler = RequestHandler<SimpleResponse>

protocol RequestTask {
    func resume()
    func cancel()
}

class RequestHandler<T: Codable> {
    enum ObservationMode {
        case both
        case onSuccess
        case onFailure
    }

    private var queue: DispatchQueue?
    private var mode: ObservationMode = .both

    private var currentTask: RequestTask? {
        willSet {
            currentTask?.cancel()
        }
    }

    private var onSuccess: ParameterClosure<T>?
    private var onFailure: ParameterClosure<ErrorResponse>?

    func start(with task: RequestTask) {
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

    deinit {
        currentTask?.cancel()
    }
}

extension RequestHandler {
    convenience init(queue: DispatchQueue = .main,
                     mode: ObservationMode = .both,
                     onSuccess: ParameterClosure<T>?,
                     onFailure: ParameterClosure<ErrorResponse>?) {
        self.init()

        self.queue = queue
        self.mode = mode
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }

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
