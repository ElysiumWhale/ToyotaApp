import Foundation

final class LostConnectionInteractor {
    private let reconnectionService: ReconnectionService

    var onSuccess: ParameterClosure<CheckUserContext>?
    var onError: ParameterClosure<ErrorResponse>?

    private lazy var requestHandler = RequestHandler<CheckUserOrSmsCodeResponse>()
        .observe(on: .main)
        .bind { [weak self] response in
            KeychainManager.set(SecretKey(response.secretKey))
            self?.onSuccess?(CheckUserContext(response: response))
        } onFailure: { [weak self] errorResponse in
            self?.onError?(errorResponse)
        }

    init(reconnectionService: ReconnectionService) {
        self.reconnectionService = reconnectionService
    }

    func reconnect() {
        guard let userId = KeychainManager<UserId>.get()?.value,
              let secretKey = KeychainManager<SecretKey>.get()?.value else {
            onError?(ErrorResponse(code: .corruptedData, message: nil))
            return
        }

        let body = CheckUserBody(userId: userId, secret: secretKey, brandId: Brand.Toyota)
        reconnectionService.checkUser(with: body, handler: requestHandler)
    }
}
