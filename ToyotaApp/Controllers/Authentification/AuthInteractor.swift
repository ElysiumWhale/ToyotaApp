import Foundation

@MainActor
final class AuthInteractor {
    private let authService: IRegistrationService

    let type: AuthScenario

    init(
        type: AuthScenario = .register,
        authService: IRegistrationService = NewInfoService()
    ) {
        self.type = type
        self.authService = authService
    }

    func sendPhone(_ phone: String) async -> Result<Void, String> {
        switch await authService.registerPhone(.init(phone: phone)) {
        case .success:
            if case .register = type {
                KeychainService.shared.set(Phone(phone))
            }
            return .success(())
        case let .failure(error):
            return .failure(error.message ?? .error(.unknownError))
        }
    }
}
