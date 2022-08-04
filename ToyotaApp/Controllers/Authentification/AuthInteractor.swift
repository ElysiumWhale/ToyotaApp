import Foundation

final class AuthInteractor {
    private let authRequestHandler = DefaultRequestHandler()
    private let authService: AuthService

    let type: AuthType

    var onSuccess: Closure?
    var onFailure: ParameterClosure<String>?

    init(type: AuthType = .register, authService: AuthService = InfoService()) {
        self.type = type
        self.authService = authService

        setupRequestHandlers()
    }

    func sendPhone(_ phone: String) {
        if case .register = type {
            KeychainManager.set(Phone(phone))
        }

        authService.registerPhone(with: .init(phone: phone),
                                  handler: authRequestHandler)
    }

    private func setupRequestHandlers() {
        authRequestHandler
            .observe(on: .main)
            .bind { [weak self] _ in
                self?.onSuccess?()
            } onFailure: { [weak self] error in
                self?.onFailure?(error.message ?? .error(.unknownError))
            }
    }
}
