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

    init(fetcher: Fetcher = DefaultAsyncFetcher()) {
        self.fetcher = fetcher
    }

    func makeRequest<Response>(
        _ request: Request,
        _ handler: RequestHandler<Response>
    ) where Response: IResponse {

        let request = buildPostRequest(
            for: request.page.rawValue,
            with: request.body.asRequestItems
        )

        let task = fetcher.fetch(request) { [weak handler] (data, response, error) in
            guard error == nil else {
                handler?.invokeFailure(.lostConnection)
                return
            }

            guard let data = data else {
                handler?.invokeFailure(.corruptedData)
                return
            }

            #if DEBUG
            let json = try? JSONSerialization.jsonObject(with: data)
            print(json ?? "Error while parsing json object")
            #endif

            let decoder = JSONDecoder()
            if let response = try? decoder.decode(Response.self, from: data) {
                handler?.invokeSuccess(response)
            } else if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                handler?.invokeFailure(errorResponse)
            } else {
                handler?.invokeFailure(.corruptedData)
            }
        }

        handler.start(with: task)
    }

    func makeRequest(_ request: Request) {
        fetcher.fetch(
            buildPostRequest(
                for: request.page.rawValue,
                with: request.body.asRequestItems
            ),
            { _, _, _ in }
        ).resume()
    }

    private func buildPostRequest(
        for page: String,
        with params: [URLQueryItem] = []
    ) -> URLRequest {
        var mainURL = UrlFactory.mainUrl
        mainURL.path.append(page)
        mainURL.queryItems = params
        var request = URLRequest(url: mainURL.url!)
        request.httpMethod = RequestType.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // MARK: - Future
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // let paramsDict = Dictionary(uniqueKeysWithValues: params.map { ($0.name, $0.value) })
        // let data = try? JSONSerialization.data(withJSONObject: paramsDict,
        //                                        options: JSONSerialisation.WritingOptions.prettyPrinted)
        // request.httpBody = data
        request.httpBody = Data(mainURL.url!.query!.utf8)
        return request
    }

    func buildImageUrl(_ path: String) -> URL? {
        guard path.isNotEmpty else {
            return nil
        }

        var query = UrlFactory.imageUrl
        query.path.append(path)
        return query.url
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
