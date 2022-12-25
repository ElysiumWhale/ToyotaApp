import Foundation

@MainActor
final class SmsCodeInteractor {
    private let authService: IRegistrationService

    let type: AuthScenario
    let phone: String

    init(
        type: AuthScenario = .register,
        phone: String,
        authService: IRegistrationService = NewInfoService()
    ) {
        self.type = type
        self.phone = phone
        self.authService = authService
    }

    func checkCode(
        code: String
    ) async -> Result<(AuthScenario, CheckUserContext?), String> {
        switch type {
        case .register:
            return await register(code)
        case let .changeNumber(userId):
            return await changeNumber(code, userId)
        }
    }

    func deleteTemporaryPhone() {
        guard case .register = type else {
            return
        }

        Task {
            _ = await authService.deleteTemporaryPhone(.init(phone: phone))
        }
    }

    private func register(
        _ code: String
    ) async -> Result<(AuthScenario, CheckUserContext?), String> {
        let body = CheckSmsCodeBody(
            phone: phone,
            code: code,
            brandId: Brand.Toyota
        )
        switch await authService.checkCode(body) {
        case let .success(response):
            if let userId = response.userId {
                KeychainManager.set(UserId(userId))
            }
            KeychainManager.set(SecretKey(response.secretKey))
            return .success((type, .init(response)))
        case let .failure(error):
            return .failure(error.message ?? .error(.unknownError))
        }
    }

    private func changeNumber(
        _ code: String,
        _ userId: String
    ) async -> Result<(AuthScenario, CheckUserContext?), String> {
        let body = ChangePhoneBody(
            userId: userId,
            code: code,
            newPhone: phone
        )
        switch await authService.changePhone(body) {
        case .success:
            KeychainManager.set(Phone(phone))
            EventNotificator.shared.notify(with: .phoneUpdate)
            return .success((type, nil))
        case let .failure(error):
            return .failure(error.message ?? .error(.unknownError))
        }
    }
}
