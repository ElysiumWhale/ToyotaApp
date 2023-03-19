import UIKit
import ComposableArchitecture

enum AddInfoScenario: Hashable {
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

    func hash(into hasher: inout Hasher) {
        switch self {
        case .register:
            hasher.combine("register")
        case let .update(userProxy):
            hasher.combine("update")
            hasher.combine(userProxy.id)
            hasher.combine(userProxy.phone)
        }
    }
}

@MainActor
enum RegisterFlow {
    struct Environment {
        let userId: String
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
            userId: environment.userId,
            profile: environment.profile,
            service: environment.personalService,
            keychain: environment.keychain
        ))
        switch routingType {
        case .selfRouted:
            let router = personalModule.ui.wrappedInNavigation(
                .appTint(.secondarySignatureRed)
            )
            router.navigationBar.prefersLargeTitles = true
            router.navigationBar.tintColor = .appTint(.secondarySignatureRed)
            return router
        case let .routed(router):
            personalModule.outputStore.setup(router, environment)
            return personalModule.ui
        case .none:
            return personalModule.ui
        }
    }

    static func makeFlowStack(
        _ router: UINavigationController,
        _ environment: Environment,
        _ cities: [City],
        _ citySelected: Bool
    ) -> [UIViewController] {
        var modules: [UIViewController] = []
        let personalModule = personalModule(PersonalPayload(
            userId: environment.userId,
            profile: environment.profile,
            service: environment.personalService,
            keychain: environment.keychain
        ))
        personalModule.outputStore.setup(router, environment)
        modules.append(personalModule.ui)

        guard environment.profile != nil else {
            return modules
        }

        let cityModule = cityModule(.init(
            cities: cities,
            service: environment.cityService,
            defaults: environment.defaults
        ))
        let addCarPayload = AddCarPayload(
            scenario: .register,
            models: [],
            colors: [],
            service: environment.carsService,
            keychain: environment.keychain
        )
        cityModule.setupOutput(
            router,
            addCarPayload
        )
        modules.append(cityModule)

        guard citySelected else {
            return modules
        }

        let addCarModule = addCarModule(addCarPayload)
        addCarModule.setupOutput(router)
        modules.append(addCarModule)

        return modules
    }

    static func endRegistrationModule() -> any EndRegistrationModule {
        EndRegistrationViewController()
    }
}

// MARK: - Personal module
extension RegisterFlow {
    struct PersonalPayload {
        let userId: String
        let profile: Profile?
        let service: PersonalInfoService
        let keychain: any ModelKeyedCodableStorage<KeychainKeys>
    }

    static func personalModule(
        _ payload: PersonalPayload
    ) -> (
        ui: UIViewController,
        outputStore: OutputStore<PersonalInfoFeature.Output>
    ) {
        let state = PersonalInfoFeature.State(
            userId: payload.userId,
            personState: .make(from: payload.profile)
        )
        let outputStore = OutputStore<PersonalInfoFeature.Output>()
        let feature = PersonalInfoFeature(
            setPersonRequest: { _ in .failure(.lostConnection) },
            storeInKeychain: { _ in },
            outputStore: outputStore
        )
        let store =  StoreOf<PersonalInfoFeature>(
            initialState: state,
            reducer: feature
        )
        let view = PersonalInfoViewController(store: store)
        return (ui: view, outputStore: outputStore)
    }
}

// MARK: - Personal module output
extension OutputStore where TOutput == PersonalInfoFeature.Output {
    @MainActor
    func setup(
        _ router: UINavigationController?,
        _ environment: RegisterFlow.Environment
    ) {
        output = { [weak router] output in
            switch output {
            case let .personDidSet(response):
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

    @MainActor
    func setupOutputServices(
        _ router: UINavigationController?,
        _ inputable: (any Inputable<ServicesInput>)?
    ) {
        withOutput { [weak router, weak inputable] output in
            switch output {
            case let .cityDidPick(city):
                router?.popViewController(animated: true)
                inputable?.input(.cityDidPick(city))
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
                let endModule = RegisterFlow.endRegistrationModule()
                endModule.modalPresentationStyle = .fullScreen
                endModule.withOutput { output in
                    switch output {
                    case .registerDidEnd:
                        // TODO: Move to upper injection level
                        NavigationService.loadMain()
                    }
                }

                router?.present(endModule, animated: true)
            case .carDidAdd(.update):
                router?.popViewController(animated: true)
            }
        }
    }
}
