import UIKit
import ComposableArchitecture

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
        let module = makeAuthModule(payload)

        switch routingType {
        case .selfRouted:
            let router = module.ui.wrappedInNavigation(
                .appTint(.secondarySignatureRed)
            )
            module.outputStore.setup(
                router,
                environment.service,
                environment.keychain
            )
            return router
        case let .routed(router):
            module.outputStore.setup(
                router,
                environment.service,
                environment.keychain
            )
            return module.ui
        case .none:
            return module.ui
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

    static func makeAuthModule(
        _ payload: AuthPayload
    ) -> (
        ui: UIViewController,
        outputStore: OutputStore<AuthFeature.Output>
    ) {
        let state = AuthFeature.State(scenario: payload.scenario)
        let outputStore = OutputStore<AuthFeature.Output>()
        let feature = AuthFeature(
            registerPhone: payload.service.registerPhone,
            storeInKeychain: {
                payload.keychain.set(Phone($0))
            },
            outputStore: outputStore
        )
        let store = Store(initialState: state, reducer: feature)
        let ui = AuthViewController(store: store)

        return (ui: ui, outputStore: outputStore)
    }
}

// MARK: - Auth output
extension OutputStore where TOutput == AuthFeature.Output {
    @MainActor
    func setup(
        _ router: UINavigationController,
        _ service: IRegistrationService,
        _ keychain: any ModelKeyedCodableStorage<KeychainKeys>
    ) {
        output = { [weak router] output in
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
                    service: service,
                    keychain: keychain
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
