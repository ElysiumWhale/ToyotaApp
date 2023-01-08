import Foundation

protocol Fetcher {
    func fetch(
        _ request: URLRequest,
        _ completion: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
    ) -> RequestTask
}

protocol AsyncFetcher {
    func fetch(_ request: URLRequest) async throws -> (Data, URLResponse)
}

struct DefaultAsyncFetcher: AsyncFetcher, Fetcher {
    private let session: URLSession

    init(timeout: TimeInterval = 20) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpCookieStorage?.cookieAcceptPolicy = .never
        session = URLSession(configuration: config)
    }

    func fetch(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }

    func fetch(
        _ request: URLRequest,
        _ completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> RequestTask {
        session.dataTask(with: request, completionHandler: completion)
    }
}
