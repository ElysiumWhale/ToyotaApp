import Foundation

@MainActor
final class AuthInteractor {
    private let authService: IRegistrationService
    private let keychain: any ModelKeyedCodableStorage<KeychainKeys>

    let type: AuthScenario

    init(
        type: AuthScenario,
        authService: IRegistrationService,
        keychain: any ModelKeyedCodableStorage<KeychainKeys>
    ) {
        self.type = type
        self.authService = authService
        self.keychain = keychain
    }

    func sendPhone(_ phone: String) async -> Result<Void, String> {
        switch await authService.registerPhone(.init(phone: phone)) {
        case .success:
            if case .register = type {
                keychain.set(Phone(phone))
            }
            return .success(())
        case let .failure(error):
            return .failure(error.message ?? .error(.unknownError))
        }
    }
}
