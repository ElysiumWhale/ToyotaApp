import Foundation

typealias Response<TResponse: IResponse> = Result<TResponse, ErrorResponse>
typealias ResponseHandler<TResponse: IResponse> = (Response<TResponse>) -> Void

struct Request {
    let page: RequestPath
    let body: IBody
}

final class NetworkService {
    static let shared = NetworkService()

    private let fetcher: Fetcher
    private let decoder: JSONDecoder

    init(
        fetcher: Fetcher = DefaultAsyncFetcher(),
        decoder: JSONDecoder = .init()
    ) {
        self.fetcher = fetcher
        self.decoder = decoder
    }

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

    private func handleResponse<Response: IResponse>(
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

        #if DEBUG
        let json = try? JSONSerialization.jsonObject(with: data)
        print(json ?? "Error while parsing json object")
        #endif

        if let response = try? decoder.decode(Response.self, from: data) {
            handler.invokeSuccess(response)
        } else if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
            handler.invokeFailure(errorResponse)
        } else {
            handler.invokeFailure(.corruptedData)
        }
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
