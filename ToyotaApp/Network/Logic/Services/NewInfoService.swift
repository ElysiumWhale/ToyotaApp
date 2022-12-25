import Foundation

typealias DefaultResponse = Result<SimpleResponse, ErrorResponse>
typealias NewResponse<TResponse> = Result<TResponse, ErrorResponse>

protocol IAuthService {
    func checkUser(
        _ body: CheckUserBody
    ) async -> Result<CheckUserOrSmsCodeResponse, ErrorResponse>
}

protocol IRegistrationService {
    func registerPhone(_ body: RegisterPhoneBody) async -> DefaultResponse
    func changePhone(_ body: ChangePhoneBody) async -> DefaultResponse
    func deleteTemporaryPhone(_ body: DeletePhoneBody) async -> DefaultResponse
    func checkCode(_ body: CheckSmsCodeBody) async -> NewResponse<CheckUserOrSmsCodeResponse>
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

// MARK: - IRegistrationService
extension NewInfoService: IRegistrationService {
    func registerPhone(_ body: RegisterPhoneBody) async -> DefaultResponse {
        await networkService.makeRequest(Request(
            page: .registration(.registerPhone), body: body
        ))
    }

    func changePhone(_ body: ChangePhoneBody) async -> DefaultResponse {
        await networkService.makeRequest(Request(
            page: .setting(.changePhone), body: body
        ))
    }

    func deleteTemporaryPhone(
        _ body: DeletePhoneBody
    ) async -> DefaultResponse {
        await networkService.makeRequest(Request(
            page: .registration(.deleteTemp), body: body
        ))
    }

    func checkCode(
        _ body: CheckSmsCodeBody
    ) async -> NewResponse<CheckUserOrSmsCodeResponse> {
        await networkService.makeRequest(Request(
            page: .registration(.checkCode), body: body
        ))
    }
}
