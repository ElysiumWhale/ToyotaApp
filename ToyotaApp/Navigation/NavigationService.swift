import UIKit

enum RoutingTypes {
    case selfRouted
    case routed(by: UINavigationController)
    case none
}

@MainActor
final class NavigationService {
    enum RegistrationStates {
        case error(message: String)
        case firstPage
        case secondPage(_ profile: Profile, _ cities: [City]?)
    }

    struct Environment {
        let service: InfoService
        let newService: NewInfoService
        let defaults: any KeyedCodableStorage<DefaultKeys>
        let keychain: any ModelKeyedCodableStorage<KeychainKeys>
    }

    static var environment = Environment(
        service: InfoService(),
        newService: NewInfoService(),
        defaults: DefaultsService.shared,
        keychain: KeychainService.shared
    )

    static var switchRootView: ((UIViewController) -> Void)?

    static func resolveNavigation(
        with context: CheckUserContext,
        fallbackCompletion: Closure
    ) {
        switch context.state {
        case .empty:
            fallbackCompletion()
        case let .main(user):
            loadMain(from: user)
        case .startRegister:
            loadRegister(.firstPage)
        case let .register(page, user, cities):
            switch page {
            case 2:
                loadRegister(.secondPage(user.profile, cities))
            default:
                fallbackCompletion()
            }
        }
    }

    // MARK: - LoadConnectionLost
    static func loadConnectionLost() {
        switchRootView?(UtilsFlow.connectionLostModule())
    }

    // MARK: - LoadAuth
    static func loadAuth(with error: String? = nil) {
        if let error = error {
            PopUp.display(.error(description: error))
        }

        switchRootView?(AuthFlow.entryPoint(
            .init(scenario: .register, service: environment.newService),
            .selfRouted
        ))
    }

    // MARK: - LoadRegister overloads
    static func loadRegister(_ state: RegistrationStates) {
        let router = UINavigationController()
        router.navigationBar.prefersLargeTitles = true
        router.navigationBar.tintColor = .appTint(.secondarySignatureRed)

        switch state {
        case let .error(message):
            PopUp.display(.error(description: message))
            fallthrough
        case .firstPage:
            let entry = RegisterFlow.entryPoint(
                .routed(by: router),
                RegisterFlow.Environment(
                    profile: nil,
                    defaults: environment.defaults,
                    keychain: environment.keychain,
                    cityService: environment.service,
                    personalService: environment.service,
                    carsService: environment.service
                )
            )
            router.setViewControllers([entry], animated: true)
            switchRootView?(router)
        case let .secondPage(profile, cities):
            let personalModule = RegisterFlow.personalModule(.init(
                profile: profile,
                service: environment.service,
                keychain: environment.keychain
            ))
            personalModule.setupOutput(router, .init(
                profile: profile,
                defaults: environment.defaults,
                keychain: environment.keychain,
                cityService: environment.service,
                personalService: environment.service,
                carsService: environment.service
            ))

            let cityPickerModule = RegisterFlow.cityModule(.init(
                cities: cities ?? [],
                service: environment.service,
                defaults: environment.defaults
            ))
            cityPickerModule.setupOutput(router, .init(
                scenario: .register,
                models: [],
                colors: [],
                service: environment.service,
                keychain: environment.keychain
            ))

            if .cityIsSelected {
                let addCarModule = RegisterFlow.addCarModule(.init(
                    scenario: .register,
                    models: [],
                    colors: [],
                    service: environment.service,
                    keychain: environment.keychain
                ))
                addCarModule.setupOutput(router)
                router.setViewControllers(
                    [personalModule, cityPickerModule, addCarModule],
                    animated: true
                )
            } else {
                router.setViewControllers(
                    [personalModule, cityPickerModule],
                    animated: true
                )
            }
            switchRootView?(router)
        }
    }

    // MARK: - LoadMain overloads
    static func loadMain(from user: RegisteredUser? = nil) {
        if let user = user {
            environment.keychain.set(user.profile.toDomain())
            if let cars = user.cars {
                environment.keychain.set(Cars(cars))
            }
        }

        switch UserInfo.make(environment.keychain) {
        case .failure:
            loadRegister(.error(message: .error(.profileLoadError)))
        case let .success(user):
            let entry = MainMenuFlow.entryPoint(.makeDefault(from: user))
            switchRootView?(entry.root)
        }
    }
}

extension MainMenuFlow.Environment {
    static func makeDefault(from user: UserProxy) -> Self {
        let infoService = InfoService()
        return .init(
            userProxy: user,
            notificator: .shared,
            defaults: DefaultsService.shared,
            keychain: KeychainService.shared,
            newsService: NewsInfoService(),
            servicesService: infoService,
            personalService: infoService,
            managersService: infoService,
            carsService: infoService,
            bookingsService: infoService,
            registrationService: NewInfoService()
        )
    }
}
