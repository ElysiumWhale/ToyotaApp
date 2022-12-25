import Foundation

typealias DefaultResponse = Result<SimpleResponse, ErrorResponse>
typealias NewResponse<TResponse> = Result<TResponse, ErrorResponse>

actor NewInfoService {
    private let networkService: NewNetworkService

    init(networkService: NewNetworkService = .init()) {
        self.networkService = networkService
    }
}
