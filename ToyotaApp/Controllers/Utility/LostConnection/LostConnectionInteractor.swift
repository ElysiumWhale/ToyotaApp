import Foundation

final class LostConnectionInteractor {
    private let requestHandler = RequestHandler<CheckUserOrSmsCodeResponse>()
    private let reconnectionService: ReconnectionService

    var onSuccess: ParameterClosure<CheckUserContext>?
    var onError: ParameterClosure<ErrorResponse>?

    init(reconnectionService: ReconnectionService) {
        self.reconnectionService = reconnectionService

        setupRequestHandlers()
    }

    func reconnect() {
        guard let userId = KeychainManager<UserId>.get()?.value,
              let secretKey = KeychainManager<SecretKey>.get()?.value else {
            onError?(ErrorResponse(code: .corruptedData, message: nil))
            return
        }

        let body = CheckUserBody(userId: userId,
                                 secret: secretKey,
                                 brandId: Brand.Toyota)
        reconnectionService.checkUser(with: body,
                                      handler: requestHandler)
    }

    private func setupRequestHandlers() {
        requestHandler
            .observe(on: .main)
            .bind { [weak self] response in
                KeychainManager.set(SecretKey(response.secretKey))
                self?.onSuccess?(CheckUserContext(response: response))
            } onFailure: { [weak self] errorResponse in
                self?.onError?(errorResponse)
            }
    }
}
