import Foundation

actor NewNetworkService {
    static let shared = NewNetworkService()

    private let jsonDecoder: JSONDecoder
    private let fetcher: AsyncFetcher

    init(
        jsonDecoder: JSONDecoder = .init(),
        fetcher: AsyncFetcher = DefaultAsyncFetcher()
    ) {
        self.jsonDecoder = jsonDecoder
        self.fetcher = fetcher
    }

    func makeRequest<TResponse: Decodable>(
        _ request: Request,
        _ acceptableCodes: Set<Int> = Set((200...299))
    ) async -> Result<TResponse, ErrorResponse> {
        let postRequest = buildPostRequest(
            for: request.page.rawValue,
            with: request.body.asRequestItems
        )

        do {
            let (data, response) = try await fetcher.fetch(postRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ErrorResponse(code: .corruptedData)
            }

            guard acceptableCodes.contains(httpResponse.statusCode) else {
                throw ErrorResponse(code: .lostConnection)
            }

            #if DEBUG
            let json = try? JSONSerialization.jsonObject(with: data)
            print("[DEBUG.NETWORK] \(json ?? "Error while parsing json object")")
            #endif

            if let result = try? jsonDecoder.decode(TResponse.self, from: data) {
                return .success(result)
            } else if let error = try? jsonDecoder.decode(ErrorResponse.self, from: data) {
                return .failure(error)
            } else {
                return .failure(ErrorResponse(code: .corruptedData))
            }
        } catch {
            return .failure(ErrorResponse(
                code: "0", message: error.localizedDescription
            ))
        }
    }

    private func buildPostRequest(
        for path: String,
        with params: [URLQueryItem] = []
    ) -> URLRequest {
        var mainURL = UrlFactory.mainUrl
        mainURL.path.append(path)
        mainURL.queryItems = params
        var request = URLRequest(url: mainURL.url!)
        request.httpMethod = RequestType.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // MARK: - Future
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // let paramsDict = Dictionary(uniqueKeysWithValues: params.map { ($0.name, $0.value) })
        // let data = try? JSONSerialization.data(withJSONObject: paramsDict,
        //                                        options: JSONSerialization.WritingOptions.prettyPrinted)
        // request.httpBody = data
        request.httpBody = Data(mainURL.url!.query!.utf8)
        return request
    }
}
