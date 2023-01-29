import UIKit

@MainActor
enum MainMenuFlow {
    static func entryPoint(for user: UserProxy) -> any NavigationRootHolder<Tabs> {
        let tbvc = MainTabBarController()

        let servicesModule = servicesModule(ServicesPayload(user: user))
        let profileModule = makeProfileModule(
            ProfilePayload(user: user)
        ) { [weak tbvc] module in
            tbvc?.tabsRoots[.profile]?.present(module, animated: true)
        }

        tbvc.setControllersForTabs(
            (newsModule(), .news),
            (servicesModule, .services),
            (profileModule, .profile)
        )

        return tbvc
    }

    static func newsModule() -> UIViewController {
        NewsViewController()
    }

    static func chatModule() -> UIViewController {
        let vc = ChatViewController()
        vc.hidesBottomBarWhenPushed = true
        return vc
    }
}

// MARK: - Profile
extension MainMenuFlow {
    struct ProfilePayload {
        let user: UserProxy
    }

    static func profileModule(
        _ payload: ProfilePayload
    ) -> any ProfileModule {
        let interactor = ProfileInteractor(user: payload.user)
        let controller = ProfileViewController(interactor: interactor)
        return controller
    }

    static func makeProfileModule(
        _ payload: ProfilePayload,
        _ router: @escaping (_ to: UIViewController) -> Void
    ) -> UIViewController {
        profileModule(payload).withOutput { output in
            switch output {
            case .logout:
                KeychainService.shared.removeAll()
                DefaultsService.shared.removeAll()
                NavigationService.loadAuth()
            case .showSettings:
                let payload = SettingsPayload(user: payload.user)
                let module = settingsModule(payload)
                let localRouter = module.wrappedInNavigation
                module.setupOutput(localRouter)
                router(localRouter)
            case .showManagers:
                let payload = ManagersPayload(userId: payload.user.id)
                let module = managersModule(payload)
                router(module.wrappedInNavigation)
            case .showCars:
                let payload = CarsPayload(user: payload.user)
                let carsModule = carsModule(payload)
                    .wrappedInNavigation
                carsModule.navigationBar.tintColor = .appTint(.secondarySignatureRed)
                router(carsModule)
            case.showBookings:
                let payload = BookingsPayload(userId: payload.user.id)
                let module = bookingsModule(payload)
                router(module.wrappedInNavigation)
            }
        }
    }
}

// MARK: - Services
extension MainMenuFlow {
    struct ServicesPayload {
        let user: UserProxy
    }

    static func servicesModule(_ payload: ServicesPayload) -> UIViewController {
        ServicesViewController(user: payload.user)
    }
}

// MARK: - Managers
extension MainMenuFlow {
    struct ManagersPayload {
        let userId: String
    }

    static func managersModule(_ payload: ManagersPayload) -> UIViewController {
        let interactor = ManagersInteractor(userId: payload.userId)
        let controller = ManagersViewController(interactor: interactor)
        return controller
    }
}

// MARK: - Settings
extension MainMenuFlow {
    struct SettingsPayload {
        let user: UserProxy
    }

    static func settingsModule(
        _ payload: SettingsPayload
    ) -> any SettingsModule {
        SettingsViewController(user: payload.user)
    }
}

// MARK: - Settings Output
extension SettingsModule {
    @MainActor
    func setupOutput(
        _ router: UINavigationController
    ) {
        withOutput { [weak router] output in
            switch output {
            case let .changePhone(userId):
                router?.pushViewController(
                    AuthFlow.authModule(authType: .changeNumber(userId)),
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
    }

    static func bookingsModule(_ payload: BookingsPayload) -> UIViewController {
        let interactor = BookingsInteractor(userId: payload.userId)
        return BookingsViewController(interactor: interactor)
    }
}

// MARK: - Cars
extension MainMenuFlow {
    struct CarsPayload {
        let user: UserProxy
    }

    static func carsModule(_ payload: CarsPayload) -> UIViewController {
        let interactor = CarsInteractor(user: payload.user)
        let controller = CarsViewController(interactor: interactor)
        return controller
    }
}
