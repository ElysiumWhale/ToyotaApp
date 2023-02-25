import UIKit

enum AuthScenario: Hashable {
    case register
    case changeNumber(_ userId: String)
}

@MainActor
enum AuthFlow {
    struct Environment {
        let scenario: AuthScenario
        let service: IRegistrationService
        let keychain: any ModelKeyedCodableStorage<KeychainKeys>
    }

    static func entryPoint(
        _ environment: Environment,
        _ routingType: RoutingTypes
    ) -> UIViewController {
        let payload = AuthPayload(
            scenario: environment.scenario,
            service: environment.service,
            keychain: environment.keychain
        )
        let module = authModule(payload)

        switch routingType {
        case .selfRouted:
            let router = module.wrappedInNavigation
            router.navigationBar.tintColor = .appTint(.secondarySignatureRed)
            module.setupOutput(router, environment.service)
            return router
        case let .routed(router):
            module.setupOutput(router, environment.service)
            return module
        case .none:
            return module
        }
    }
}

// MARK: - Auth module
extension AuthFlow {
    struct AuthPayload {
        let scenario: AuthScenario
        let service: IRegistrationService
        let keychain: any ModelKeyedCodableStorage<KeychainKeys>
    }

    static func authModule(
        _ payload: AuthPayload
    ) -> any AuthModule {
        let interactor = AuthInteractor(
            type: payload.scenario,
            authService: payload.service,
            keychain: payload.keychain
        )
        )
        return AuthViewController(interactor: interactor)
    }
}

// MARK: - Auth output
extension AuthModule {
    @MainActor
    func setupOutput(
        _ router: UINavigationController,
        _ service: IRegistrationService
    ) {
        withOutput { [weak router] output in
            switch output {
            case .showAgreement:
                router?.present(
                    UtilsFlow.agreementModule().wrappedInNavigation,
                    animated: true
                )
            case let .successPhoneCheck(phone, authScenario):
                let codePayload = AuthFlow.CodePayload(
                    phone: phone,
                    scenario: authScenario,
                    service: service
                )
                let codeModule = AuthFlow.codeModule(codePayload)
                if let router {
                    codeModule.setupOutput(router)
                }

                router?.pushViewController(
                    codeModule,
                    animated: true
                )
            }
        }
    }
}

// MARK: - Code module
extension AuthFlow {
    struct CodePayload {
        let phone: String
        let scenario: AuthScenario
        let service: IRegistrationService
    }

    static func codeModule(
        _ payload: CodePayload
    ) -> any SmsCodeModule {
        let interactor = SmsCodeInteractor(
            type: payload.scenario,
            phone: payload.phone,
            authService: payload.service
        )
        return SmsCodeViewController(interactor: interactor)
    }
}

// MARK: - Code output
extension SmsCodeModule {
    @MainActor
    func setupOutput(_ router: UINavigationController) {
        withOutput { [weak router] output in
            switch output {
            case let .successfulCheck(.register, context):
                guard let context else {
                    return
                }

                NavigationService.resolveNavigation(context: context) {
                    NavigationService.loadRegister(.error(message: .error(.serverBadResponse)))
                }
            case .successfulCheck(.changeNumber, _):
                router?.popViewController(animated: true)
            }
        }
    }
}
