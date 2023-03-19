import Foundation

final class LostConnectionInteractor {
    private let requestHandler = RequestHandler<CheckUserOrSmsCodeResponse>()
    private let reconnectionService: ReconnectionService
    private let keychain: KeychainService

    var onSuccess: ParameterClosure<CheckUserContext>?
    var onError: ParameterClosure<ErrorResponse>?

    init(
        reconnectionService: ReconnectionService,
        keychain: KeychainService = .shared
    ) {
        self.reconnectionService = reconnectionService
        self.keychain = keychain

        setupRequestHandlers()
    }

    func reconnect() {
        guard
            let userId: UserId = keychain.get(),
            let secretKey: SecretKey = keychain.get()
        else {
            onError?(ErrorResponse(code: .corruptedData, message: nil))
            return
        }

        let body = CheckUserBody(
            userId: userId.value,
            secret: secretKey.value,
            brandId: Brand.Toyota
        )
        reconnectionService.checkUser(
            with: body,
            requestHandler
        )
    }

    private func setupRequestHandlers() {
        requestHandler
            .observe(on: .main)
            .bind { [weak self] response in
                self?.keychain.set(SecretKey(value: response.secretKey))
                self?.onSuccess?(CheckUserContext(response: response))
            } onFailure: { [weak self] errorResponse in
                self?.onError?(errorResponse)
            }
    }
}
