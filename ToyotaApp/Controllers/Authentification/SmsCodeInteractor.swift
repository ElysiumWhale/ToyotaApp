import Foundation

final class SmsCodeInteractor {
    private let authService: AuthService

    private lazy var registerHandler = RequestHandler<CheckUserOrSmsCodeResponse>()
        .observe(on: .main)
        .bind { [weak self] data in
            KeychainManager.set(UserId(data.userId!))
            KeychainManager.set(SecretKey(data.secretKey))
            self?.handleSuccess(response: data)
        } onFailure: { [weak self] error in
            self?.onError?(error.message ?? .error(.unknownError))
        }

    private lazy var changeNumberHandler = RequestHandler<SimpleResponse>()
        .observe(on: .main)
        .bind { [weak self] _ in
            self?.handleSuccess()
        } onFailure: { [weak self] error in
            self?.onError?(error.message ?? .error(.unknownError))
        }

    let type: AuthType
    let phone: String

    var onSuccess: ParameterClosure<(AuthType, CheckUserContext?)>?
    var onError: ParameterClosure<String>?

    init(type: AuthType = .register, phone: String, authService: AuthService = InfoService()) {
        self.type = type
        self.phone = phone
        self.authService = authService
    }

    func checkCode(code: String) {
        switch type {
            case .register:
                let body = CheckSmsCodeBody(phone: phone, code: code, brandId: Brand.Toyota)
                authService.checkCode(with: body, handler: registerHandler)
            case .changeNumber:
                let id = KeychainManager<UserId>.get()!.value
                let body = ChangePhoneBody(userId: id, code: code, newPhone: phone)
                authService.changePhone(with: body, handler: changeNumberHandler)
        }
    }

    func deleteTemporaryPhone() {
        guard case .register = type else {
            return
        }

        authService.deleteTemporaryPhone(with: .init(phone: phone))
    }

    private func handleSuccess(response: CheckUserOrSmsCodeResponse? = nil) {
        onSuccess?((type, .init(response)))
    }
}
