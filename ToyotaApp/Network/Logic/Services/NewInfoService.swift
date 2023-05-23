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
    func setPerson(_ body: SetProfileBody) async -> NewResponse<CitiesResponse>
}

protocol IBookingService {
    func bookService(_ body: BookServiceBody) async -> DefaultResponse
}

protocol ICitiesService {
    func getCities(_ body: GetCitiesBody) async -> NewResponse<CitiesResponse>
}

actor NewInfoService {
    private let networkService: NetworkService

    init(networkService: NetworkService = .init()) {
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

    func setPerson(
        _ body: SetProfileBody
    ) async -> NewResponse<CitiesResponse> {
        await networkService.makeRequest(Request(
            page: .registration(.setProfile), body: body))
    }
}

// MARK: - IBookingService
extension NewInfoService: IBookingService {
    func bookService(_ body: BookServiceBody) async -> DefaultResponse {
        await networkService.makeRequest(Request(
            page: .services(.bookService), body: body
        ))
    }
}

// MARK: - ICitiesService
extension NewInfoService: ICitiesService {
    func getCities(_ body: GetCitiesBody) async -> NewResponse<CitiesResponse> {
        await networkService.makeRequest(Request(
            page: .profile(.getCities), body: body
        ))
    }
}
