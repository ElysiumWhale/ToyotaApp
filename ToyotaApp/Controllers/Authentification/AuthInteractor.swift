import Foundation

final class AuthInteractor {
    private let authService: AuthService

    let type: AuthType

    var onSuccess: Closure?
    var onFailure: ParameterClosure<String>?

    private lazy var authRequestHandler: RequestHandler<SimpleResponse> = {
        RequestHandler<SimpleResponse>()
            .observe(on: .main)
            .bind { [weak self] _ in
                self?.onSuccess?()
            } onFailure: { [weak self] error in
                self?.onFailure?(error.message ?? .error(.unknownError))
            }
    }()

    init(type: AuthType = .register, authService: AuthService = InfoService()) {
        self.type = type
        self.authService = authService
    }

    func sendPhone(_ phone: String) {
        if case .register = type {
            KeychainManager.set(Phone(phone))
        }

        authService.registerPhone(with: .init(phone: phone),
                                  handler: authRequestHandler)
    }
}
