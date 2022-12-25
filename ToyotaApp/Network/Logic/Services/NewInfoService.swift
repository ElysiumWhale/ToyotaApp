import Foundation

typealias DefaultResponse = Result<SimpleResponse, ErrorResponse>
typealias NewResponse<TResponse> = Result<TResponse, ErrorResponse>

protocol IAuthService {
    func checkUser(
        _ body: CheckUserBody
    ) async -> Result<CheckUserOrSmsCodeResponse, ErrorResponse>
}

actor NewInfoService {
    private let networkService: NewNetworkService

    init(networkService: NewNetworkService = .init()) {
        self.networkService = networkService
    }
}

// MARK: - IAuthService
extension NewInfoService: IAuthService {
    func checkUser(
        _ body: CheckUserBody
    ) async -> Result<CheckUserOrSmsCodeResponse, ErrorResponse> {
        await networkService.makeRequest(Request(
            page: .start(.checkUser), body: body
        ))
    }
}
