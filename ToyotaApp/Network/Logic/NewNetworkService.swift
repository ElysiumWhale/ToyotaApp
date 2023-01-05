import Foundation

actor NewNetworkService {
    static let shared = NewNetworkService()

    private let decoder: JSONDecoder
    private let fetcher: AsyncFetcher

    init(
        decoder: JSONDecoder = .init(),
        fetcher: AsyncFetcher = DefaultAsyncFetcher()
    ) {
        self.decoder = decoder
        self.fetcher = fetcher
    }

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

        #if DEBUG
        let json = try? JSONSerialization.jsonObject(with: data)
        print("[DEBUG.NETWORK] \(json ?? "Error while parsing json object")")
        #endif

        if let result = try? decoder.decode(TResponse.self, from: data) {
            return .success(result)
        } else if let error = try? decoder.decode(ErrorResponse.self, from: data) {
            return .failure(error)
        } else {
            return .failure(ErrorResponse(code: .corruptedData))
        }
    }
}

extension String: Error { }
