import UIKit

@MainActor
enum MainMenuFlow {
    struct Environment {
        let userProxy: UserProxy
        let notificator: EventNotificator
        let defaults: any KeyedCodableStorage<DefaultKeys>
        let keychain: any ModelKeyedCodableStorage<KeychainKeys>
        let newsService: NewsService
        let servicesService: ServicesService
        let personalService: PersonalInfoService
        let managersService: ManagersService
        let carsService: CarsService
        let bookingsService: BookingsService
        let citiesService: CitiesService
        let registrationService: IRegistrationService
    }

    static func entryPoint(
        _ environment: Environment
    ) -> any NavigationRootHolder<Tabs> {
        let tbvc = MainTabBarController()

        let servicesModule = servicesModule(ServicesPayload(
            user: environment.userProxy,
            service: environment.servicesService
        ))
        servicesModule.setupOutput(environment) { [weak tbvc] in
            tbvc?.tabsRoots[.services]
        }

        let newsModule = newsModule(NewsPayload(
            service: environment.newsService,
            defaults: environment.defaults
        ))

        let profileModule = makeProfileModule(environment) { [weak tbvc] in
            tbvc?.tabsRoots[.profile]
        }

        tbvc.setControllersForTabs(
            (newsModule, .news),
            (servicesModule, .services),
            (profileModule, .profile)
        )

        return tbvc
    }

    static func chatModule() -> UIViewController {
        let vc = ChatViewController()
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
}

// MARK: - News
extension MainMenuFlow {
    struct NewsPayload {
        let service: NewsService
        let defaults: any KeyedCodableStorage<DefaultKeys>
    }

    static func newsModule(
        _ payload: NewsPayload
    ) -> UIViewController {
        let newsInteractor = NewsInteractor(
            newsService: payload.service,
            defaults: payload.defaults
        )
        return NewsViewController(interactor: newsInteractor)
    }
}

// MARK: - Profile
extension MainMenuFlow {
    struct ProfilePayload {
        let user: UserProxy
        let service: PersonalInfoService
    }

    static func profileModule(
        _ payload: ProfilePayload
    ) -> any ProfileModule {
        let interactor = ProfileInteractor(
            user: payload.user,
            service: payload.service
        )
        return ProfileViewController(interactor: interactor)
    }

    static func makeProfileModule(
        _ environment: Environment,
        _ router: @escaping () -> UINavigationController?
    ) -> UIViewController {
        profileModule(ProfilePayload(
            user: environment.userProxy,
            service: environment.personalService
        )).withOutput { output in
            switch output {
            case .logout:
                environment.keychain.removeAll()
                environment.defaults.removeAll()
                NavigationService.loadAuth()
            case .showSettings:
                let payload = SettingsPayload(
                    user: environment.userProxy,
                    notificator: environment.notificator
                )
                let module = settingsModule(payload)
                let localRouter = module.wrappedInNavigation
                module.setupOutput(localRouter, environment.registrationService)
                router()?.present(localRouter, animated: true)
            case .showManagers:
                let payload = ManagersPayload(
                    userId: environment.userProxy.id,
                    service: environment.managersService
                )
                let module = managersModule(payload)
                router()?.present(module.wrappedInNavigation, animated: true)
            case .showCars:
                let payload = CarsPayload(
                    user: environment.userProxy,
                    service: environment.carsService,
                    notificator: environment.notificator
                )
                let carsModule = carsModule(payload)
                let carsRouter = carsModule.wrappedInNavigation
                carsRouter.navigationBar.tintColor = .appTint(.secondarySignatureRed)
                carsModule.setupOutput(carsRouter) {
                    RegisterFlow.addCarModule(.init(
                        scenario: .update(with: environment.userProxy),
                        models: $0,
                        colors: $1,
                        service: environment.carsService,
                        keychain: environment.keychain
                    ))
                }
                router()?.present(carsRouter, animated: true)
            case.showBookings:
                let payload = BookingsPayload(
                    userId: environment.userProxy.id,
                    service: environment.bookingsService
                )
                let module = bookingsModule(payload)
                router()?.present(module.wrappedInNavigation, animated: true)
            }
        }
    }
}

// MARK: - Services
extension MainMenuFlow {
    struct ServicesPayload {
        let user: UserProxy
        let service: ServicesService
    }

    static func servicesModule(
        _ payload: ServicesPayload
    ) -> any ServicesModule {
        let interactor = ServicesInteractor(
            user: payload.user,
            service: payload.service
        )
        return ServicesViewController(interactor: interactor)
    }
}

extension ServicesModule {
    @MainActor
    func setupOutput(
        _ environment: MainMenuFlow.Environment,
        _ router: @escaping () -> UINavigationController?
    ) {
        withOutput { [weak self] output in
            switch output {
            case .showChat:
                let chatModule = MainMenuFlow.chatModule()
                router()?.pushViewController(chatModule, animated: true)
            case .showCityPick:
                let cityModule = RegisterFlow.cityModule(.init(
                    cities: [],
                    service: environment.citiesService,
                    defaults: environment.defaults
                ))
                cityModule.hidesBottomBarWhenPushed = true
                cityModule.setupOutputServices(router(), self)
                router()?.pushViewController(cityModule, animated: true)
            case let .showServiceOrder(type):
                guard let viewType = type.serviceViewType else {
                    return
                }

                let serviceModule = ServicesFlow.serviceOrderModule(.init(
                    serviceType: type,
                    controlType: viewType,
                    user: environment.userProxy
                ))
                serviceModule.setupOutput(router())
                router()?.pushViewController(serviceModule, animated: true)
            }
        }
    }
}

// MARK: - Managers
extension MainMenuFlow {
    struct ManagersPayload {
        let userId: String
        let service: ManagersService
    }

    static func managersModule(
        _ payload: ManagersPayload
    ) -> UIViewController {
        let interactor = ManagersInteractor(
            userId: payload.userId,
            managersService: payload.service
        )
        return ManagersViewController(interactor: interactor)
    }
}

// MARK: - Settings
extension MainMenuFlow {
    struct SettingsPayload {
        let user: UserProxy
        let notificator: EventNotificator
    }

    static func settingsModule(
        _ payload: SettingsPayload
    ) -> any SettingsModule {
        SettingsViewController(
            user: payload.user,
            notificator: payload.notificator
        )
    }
}

// MARK: - Settings Output
extension SettingsModule {
    @MainActor
    func setupOutput(
        _ router: UINavigationController?,
        _ service: IRegistrationService
    ) {
        withOutput { [weak router] output in
            switch output {
            case let .changePhone(userId):
                guard let router else {
                    return
                }

                let environment = AuthFlow.Environment(
                    scenario: .changeNumber(userId),
                    service: service
                )
                router.pushViewController(
                    AuthFlow.entryPoint(environment, .routed(by: router)),
                    animated: true
                )
            case .showAgreement:
                router?.present(
                    UtilsFlow.agreementModule().wrappedInNavigation,
                    animated: true
                )
            }
        }
    }
}

// MARK: - Bookings
extension MainMenuFlow {
    struct BookingsPayload {
        let userId: String
        let service: BookingsService
    }

    static func bookingsModule(
        _ payload: BookingsPayload
    ) -> UIViewController {
        let interactor = BookingsInteractor(
            userId: payload.userId,
            bookingsService: payload.service
        )
        return BookingsViewController(interactor: interactor)
    }
}

// MARK: - Cars
extension MainMenuFlow {
    struct CarsPayload {
        let user: UserProxy
        let service: CarsService
        let notificator: EventNotificator
    }

    static func carsModule(_ payload: CarsPayload) -> any CarsModule {
        let interactor = CarsInteractor(
            carsService: payload.service,
            user: payload.user
        )
        return CarsViewController(
            interactor: interactor,
            notificator: payload.notificator
        )
    }
}

// MARK: - Cars module output
extension CarsModule {
    @MainActor
    func setupOutput(
        _ router: UINavigationController?,
        _ addCarFactory: @escaping ([Model], [Color]) -> any AddCarModule
    ) {
        withOutput { [weak router] output in
            switch output {
            case let .addCar(models, colors):
                let addCarModule = addCarFactory(models, colors)
                addCarModule.setupOutput(router)
                router?.pushViewController(addCarModule, animated: true)
            }
        }
    }
}
