import Foundation

final class SmsCodeInteractor {
    private let registerHandler = RequestHandler<CheckUserOrSmsCodeResponse>()
    private let changeNumberHandler = DefaultRequestHandler()
    private let authService: AuthService

    let type: AuthScenario
    let phone: String

    var onSuccess: ParameterClosure<(AuthScenario, CheckUserContext?)>?
    var onError: ParameterClosure<String>?

    init(type: AuthScenario = .register,
         phone: String,
         authService: AuthService = InfoService()) {

        self.type = type
        self.phone = phone
        self.authService = authService

        setupRequestHandlers()
    }

    func checkCode(code: String) {
        switch type {
        case .register:
            let body = CheckSmsCodeBody(phone: phone,
                                        code: code,
                                        brandId: Brand.Toyota)
            authService.checkCode(with: body, handler: registerHandler)
        case .changeNumber:
            let id = KeychainManager<UserId>.get()!.value
            let body = ChangePhoneBody(userId: id,
                                       code: code,
                                       newPhone: phone)
            authService.changePhone(with: body,
                                    handler: changeNumberHandler)
        }
    }

    func deleteTemporaryPhone() {
        guard case .register = type else {
            return
        }

        authService.deleteTemporaryPhone(with: .init(phone: phone))
    }

    private func setupRequestHandlers() {
        registerHandler
            .observe(on: .main)
            .bind { [weak self] response in
                if let userId = response.userId {
                    KeychainManager.set(UserId(userId))
                }
                KeychainManager.set(SecretKey(response.secretKey))
                self?.handleSuccess(response)
            } onFailure: { [weak self] error in
                self?.onError?(error.message ?? .error(.unknownError))
            }

        changeNumberHandler
            .observe(on: .main)
            .bind { [weak self] _ in
                self?.handleSuccess()
            } onFailure: { [weak self] error in
                self?.onError?(error.message ?? .error(.unknownError))
            }
    }

    private func handleSuccess(_ response: CheckUserOrSmsCodeResponse? = nil) {
        if type == .changeNumber {
            KeychainManager.set(Phone(phone))
            EventNotificator.shared.notify(with: .phoneUpdate)
        }

        onSuccess?((type, .init(response)))
    }
}
