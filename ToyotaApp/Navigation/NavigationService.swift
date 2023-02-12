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
        context: CheckUserContext,
        fallbackCompletion: Closure
    ) {
        switch context {
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
        let module = UtilsFlow.reconnectionModule(
            reconnectionService: environment.service
        )
        module.withOutput { output in
            switch output {
            case let .didReconnect(context):
                resolveNavigation(context: context) {
                    loadAuth()
                }
            case let .didReceiveError(message):
                loadAuth(with: message)
            }
        }
        switchRootView?(module)
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

    // MARK: - LoadRegister
    static func loadRegister(_ state: RegistrationStates) {
        let router = UINavigationController()
        router.navigationBar.prefersLargeTitles = true
        router.navigationBar.tintColor = .appTint(.secondarySignatureRed)

        var payloadProfile: Profile? = nil
        var payloadCities: [City] = []

        switch state {
        case let .error(message):
            PopUp.display(.error(description: message))
        case .firstPage:
            break
        case let .secondPage(profile, cities):
            payloadProfile = profile
            payloadCities = cities ?? []
        }

        let flowStack = RegisterFlow.makeFlowStack(
            router,
            RegisterFlow.Environment(
                profile: payloadProfile,
                defaults: environment.defaults,
                keychain: environment.keychain,
                cityService: environment.service,
                personalService: environment.service,
                carsService: environment.service
            ),
            payloadCities,
            .cityIsSelected(environment.defaults)
        )
        router.setViewControllers(flowStack, animated: true)
        switchRootView?(router)
    }

    // MARK: - LoadMain
    typealias UserInfoFactory = (
        any ModelKeyedCodableStorage<KeychainKeys>
    ) -> Result<UserProxy, AppErrors>

    static func loadMain(
        from user: RegisteredUser? = nil,
        userInfoFactory: UserInfoFactory = UserInfo.make
    ) {
        if let user = user {
            environment.keychain.set(user.profile.toDomain())
            if let cars = user.cars {
                environment.keychain.set(Cars(cars))
            }
        }

        switch userInfoFactory(environment.keychain) {
        case let .failure(error):
            switch error {
            case .noUserIdAndPhone:
                loadAuth(with: .error(.profileLoadError))
            default:
                loadRegister(.error(message: .error(.profileLoadError)))
            }
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
            citiesService: infoService,
            registrationService: NewInfoService()
        )
    }
}
