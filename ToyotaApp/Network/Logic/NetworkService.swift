import Foundation

typealias Response<TResponse: IResponse> = Result<TResponse, ErrorResponse>
typealias ResponseHandler<TResponse: IResponse> = (Response<TResponse>) -> Void

struct Request {
    let page: RequestPath
    let body: IBody
}

final class NetworkService {
    static let shared = NetworkService()

    private let fetcher: Fetcher & AsyncFetcher
    private let decoder: JSONDecoder

    init(
        fetcher: Fetcher & AsyncFetcher = DefaultAsyncFetcher(),
        decoder: JSONDecoder = .init()
    ) {
        self.fetcher = fetcher
        self.decoder = decoder
    }

    // MARK: - Closure based request
    func makeRequest<Response>(
        _ request: Request,
        _ handler: RequestHandler<Response>
    ) where Response: IResponse {

        let request = RequestFactory.make(
            for: request.page.rawValue,
            with: request.body.asRequestItems
        )

        let task = fetcher.fetch(request) { [weak handler, weak self] in
            if let self, let handler {
                self.handleResponse($0, $1, $2, handler)
            }
        }

        handler.start(with: task)
    }

    func makeRequest(_ request: Request) {
        fetcher.fetch(
            RequestFactory.make(
                for: request.page.rawValue,
                with: request.body.asRequestItems
            ),
            { _, _, _ in }
        ).resume()
    }

    // MARK: - Async/Await based request
    func makeRequest<TResponse: Decodable>(
        _ request: Request,
        _ acceptableCodes: Set<Int> = Set((200...299))
    ) async -> Result<TResponse, ErrorResponse> {
        let postRequest = RequestFactory.make(
            for: request.page.rawValue,
            with: request.body.asRequestItems
        )

        let response = try? await fetcher.fetch(postRequest)
        guard let httpResponse = response?.1 as? HTTPURLResponse,
              let data = response?.0 else {
            return .failure(ErrorResponse(code: .corruptedData))
        }

        guard acceptableCodes.contains(httpResponse.statusCode) else {
            return .failure(ErrorResponse(code: .lostConnection))
        }

        debugLog(data)

        if let result = try? decoder.decode(TResponse.self, from: data) {
            return .success(result)
        } else if let error = try? decoder.decode(ErrorResponse.self, from: data) {
            return .failure(error)
        } else {
            return .failure(ErrorResponse(code: .corruptedData))
        }
    }
}

// MARK: - Helper
private extension NetworkService {
    func handleResponse<Response: IResponse>(
        _ data: Data?,
        _ response: URLResponse?,
        _ error: Error?,
        _ handler: RequestHandler<Response>
    ) {
        guard error == nil else {
            handler.invokeFailure(.lostConnection)
            return
        }

        guard let data = data else {
            handler.invokeFailure(.corruptedData)
            return
        }

        debugLog(data)

        if let response = try? decoder.decode(Response.self, from: data) {
            handler.invokeSuccess(response)
        } else if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
            handler.invokeFailure(errorResponse)
        } else {
            handler.invokeFailure(.corruptedData)
        }
    }
}

// MARK: - Debug Log
private extension NetworkService {
    func debugLog(_ data: Data) {
        #if DEBUG
        let json = try? JSONSerialization.jsonObject(with: data)
        print(json ?? "Error while parsing json object")
        #endif
    }
}

extension URLSessionDataTask: RequestTask { }

// MARK: - Request items
typealias RequestItem = (key: RequestKeys, value: String?)
typealias RequestItems = [RequestItem]

extension Array where Element == RequestItem {
    var asQueryItems: [URLQueryItem] {
        map(URLQueryItem.init)
    }
}
