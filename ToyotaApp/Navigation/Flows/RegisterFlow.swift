import UIKit

enum AddInfoScenario: Equatable {
    case register
    case update(with: UserProxy)

    static func == (lhs: AddInfoScenario, rhs: AddInfoScenario) -> Bool {
        switch (lhs, rhs) {
        case (register, register), (update, update):
            return true
        default:
            return false
        }
    }
}

@MainActor
enum RegisterFlow {
    struct Environment {
        let profile: Profile?
        let defaults: any KeyedCodableStorage<DefaultKeys>
        let keychain: any ModelKeyedCodableStorage<KeychainKeys>
        let cityService: CitiesService
        let personalService: PersonalInfoService
        let carsService: CarsService
    }

    static func entryPoint(
        _ routingType: RoutingTypes,
        _ environment: Environment
    ) -> UIViewController {

        let personalModule = personalModule(PersonalPayload(
            profile: environment.profile,
            service: environment.personalService,
            keychain: environment.keychain
        ))
        switch routingType {
        case .selfRouted:
            let router = personalModule.wrappedInNavigation
            router.navigationBar.prefersLargeTitles = true
            router.navigationBar.tintColor = .appTint(.secondarySignatureRed)
            return router
        case let .routed(router):
            personalModule.setupOutput(router, environment)
            return personalModule
        case .none:
            return personalModule
        }
    }

    static func endRegistrationModule() -> UIViewController {
        EndRegistrationViewController()
    }
}

// MARK: - Personal module
extension RegisterFlow {
    struct PersonalPayload {
        let profile: Profile?
        let service: PersonalInfoService
        let keychain: any ModelKeyedCodableStorage<KeychainKeys>
    }

    static func personalModule(_ payload: PersonalPayload) -> any PersonalInfoModule {
        let interactor = PersonalInfoInteractor(
            state: .from(payload.profile),
            service: payload.service,
            keychain: payload.keychain
        )
        let view = PersonalInfoView(interactor: interactor)
        interactor.view = view
        return view
    }
}

// MARK: - Personal module output
extension PersonalInfoModule {
    @MainActor
    func setupOutput(
        _ router: UINavigationController?,
        _ environment: RegisterFlow.Environment
    ) {
        withOutput { [weak router] output in
            switch output {
            case let .profileDidSet(response):
                let cityModule = RegisterFlow.cityModule(.init(
                    cities: response.cities,
                    service: environment.cityService,
                    defaults: environment.defaults
                ))
                cityModule.setupOutput(router, RegisterFlow.AddCarPayload(
                    scenario: .register,
                    models: response.models,
                    colors: response.colors,
                    service: environment.carsService,
                    keychain: environment.keychain
                ))

                router?.pushViewController(cityModule, animated: true)
            }
        }
    }
}

// MARK: - City module
extension RegisterFlow {
    struct CityModulePayload {
        let cities: [City]
        let service: CitiesService
        let defaults: any KeyedCodableStorage<DefaultKeys>
    }

    static func cityModule(
        _ payload: CityModulePayload
    ) -> any CityPickerModule {
        let interactor = CityPickerInteractor(
            cities: payload.cities,
            service: payload.service,
            defaults: payload.defaults
        )
        let module = CityPickerViewController(interactor: interactor)
        interactor.view = module
        return module
    }
}

// MARK: - City module output
extension CityPickerModule {
    @MainActor
    func setupOutput(
        _ router: UINavigationController?,
        _ addCarPayload: RegisterFlow.AddCarPayload
    ) {
        withOutput { [weak router] output in
            switch output {
            case .cityDidPick:
                let addCarModule = RegisterFlow.addCarModule(.init(
                    scenario: addCarPayload.scenario,
                    models: addCarPayload.models,
                    colors: addCarPayload.colors,
                    service: addCarPayload.service,
                    keychain: addCarPayload.keychain
                ))
                addCarModule.setupOutput(router)

                router?.pushViewController(addCarModule, animated: true)
            }
        }
    }
}

// MARK: - Add car module
extension RegisterFlow {
    struct AddCarPayload {
        let scenario: AddInfoScenario
        let models: [Model]
        let colors: [Color]
        let service: CarsService
        let keychain: any ModelKeyedCodableStorage<KeychainKeys>
    }

    static func addCarModule(
        _ payload: AddCarPayload
    ) -> any AddCarModule {
        let interactor = AddCarInteractor(
            type: payload.scenario,
            models: payload.models,
            colors: payload.colors,
            service: payload.service,
            keychain: payload.keychain
        )
        let vc = AddCarViewController(interactor: interactor)
        interactor.view = vc
        return vc
    }
}

// MARK: - Add car module output
extension AddCarModule {
    @MainActor
    func setupOutput(
        _ router: UINavigationController?
    ) {
        withOutput { [weak router] output in
            switch output {
            case .carDidAdd(.register):
                let endModule = EndRegistrationViewController()
                endModule.modalPresentationStyle = .fullScreen
                router?.present(endModule, animated: true)
            case .carDidAdd(.update):
                router?.popViewController(animated: true)
            }
        }
    }
}
