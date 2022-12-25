import Foundation

protocol AsyncFetcher {
    func fetch(_ request: URLRequest) async throws -> (Data, URLResponse)
}

struct DefaultAsyncFetcher: AsyncFetcher {
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
}
