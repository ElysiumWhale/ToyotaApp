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
                let codeModule = AuthFlow.makeSmsCodeModule(codePayload)
                if let router {
                    codeModule.outputStore.setup(router)
                }

                router?.pushViewController(
                    codeModule.ui,
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
        let keychain: any ModelKeyedCodableStorage<KeychainKeys>
    }

    static func makeSmsCodeModule(
        _ payload: CodePayload
    ) -> (
        ui: UIViewController,
        outputStore: OutputStore<SmsCodeFeature.Output>
    ) {
        let state = SmsCodeFeature.State(
            scenario: payload.scenario,
            phone: payload.phone
        )
        let outputStore = OutputStore<SmsCodeFeature.Output>()
        let feature = SmsCodeFeature(
            outputStore: outputStore,
            storeInKeychain: { model in payload.keychain.set(model) },
            deleteTemporaryPhoneRequest: { phone in
                _ = await payload.service.deleteTemporaryPhone(
                    DeletePhoneBody(phone: phone)
                )
            },
            checkCodeRequest: SmsCodeRequest(
                service: payload.service,
                phone: payload.phone
            ).make
        )
        let store = Store(initialState: state, reducer: feature)
        let ui = SmsCodeViewController(store: store)

        return (ui, outputStore)
    }
}

// MARK: - Code output
extension OutputStore where TOutput == SmsCodeFeature.Output {
    @MainActor
    func setup(_ router: UINavigationController) {
        output = { [weak router] output in
            switch output {
            case let .successfulCodeCheck(.register, context):
                guard let context else {
                    assertionFailure("Context should exist when register")
                    return
                }

                NavigationService.resolveNavigation(context: context) {
                    NavigationService.loadRegister(.error(message: .error(.serverBadResponse)))
                }
            case .successfulCodeCheck(.changeNumber, _):
                PopUp.display(.success(.common(.phoneChanged)))
                EventNotificator.shared.notify(with: .phoneUpdate)
                router?.popToRootViewController(animated: true)
            }
        }
    }
}

extension AuthFlow {
    struct SmsCodeRequest {
        private let service: IRegistrationService
        private let phone: String

        init(service: IRegistrationService, phone: String) {
            self.service = service
            self.phone = phone
        }

        func make(
            _ code: String,
            scenario: AuthScenario
        ) async -> Result<CheckUserOrSmsCodeResponse?, ErrorResponse> {
            switch scenario {
            case .register:
                return await service.checkCode(CheckSmsCodeBody(
                    phone: phone,
                    code: code,
                    brandId: Brand.Toyota
                )).map { $0 }
            case let .changeNumber(userId):
                return await service.changePhone(ChangePhoneBody(
                    userId: userId,
                    code: code,
                    newPhone: phone
                )).map { _ in nil }
            }
        }
    }
}
