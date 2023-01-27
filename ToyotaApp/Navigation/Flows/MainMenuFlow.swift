import UIKit

@MainActor
enum MainMenuFlow {
    static func entryPoint(for user: UserProxy) -> any NavigationRootHolder<Tabs> {
        let tbvc = MainTabBarController()

        let payload = ProfilePayload(user: user)
        let profileModule = makeProfileModule(with: payload) { [weak tbvc] in
            tbvc?.tabsRoots[.profile]
        }

        let servicesModule = servicesModule(with: ServicesPayload(user: user))

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

    static func profileModule(with payload: ProfilePayload) -> ProfileModule {
        let interactor = ProfileInteractor(user: payload.user)
        let controller = ProfileViewController(interactor: interactor)
        return controller
    }

    static func makeProfileModule(
        with payload: ProfilePayload,
        navigationFactory: @escaping ValueClosure<UINavigationController?>
    ) -> UIViewController {

        let profileModule = profileModule(with: payload)

        profileModule.onShowCars = {
            let carsModule = carsModule(with: CarsPayload(user: payload.user))
                .wrappedInNavigation
            carsModule.navigationBar.tintColor = .appTint(.secondarySignatureRed)
            navigationFactory()?.present(
                carsModule, animated: true
            )
        }

        profileModule.onShowBookings = {
            navigationFactory()?.present(
                bookingsModule(with: BookingsPayload(userId: payload.user.id))
                    .wrappedInNavigation,
                animated: true
            )
        }

        profileModule.onShowManagers = {
            navigationFactory()?.present(
                managersModule(with: ManagersPayload(userId: payload.user.id))
                    .wrappedInNavigation,
                animated: true
            )
        }

        profileModule.onShowSettings = {
            let module = settingsModule(with: SettingsPayload(user: payload.user))
            let navigation = module.wrappedInNavigation

            module.withOutput { [weak navigation] output in
                switch output {
                case .showAgreement:
                    navigation?.present(
                        UtilsFlow.agreementModule().wrappedInNavigation,
                        animated: true
                    )
                case let .changePhone(userId):
                    navigation?.pushViewController(
                        AuthFlow.authModule(authType: .changeNumber(userId)),
                        animated: true
                    )
                }
            }

            navigationFactory()?.present(navigation, animated: true)
        }

        profileModule.onLogout = {
            PopUp.displayChoice(
                with: .common(.actionConfirmation),
                description: .question(.quit),
                confirmText: .common(.yes),
                declineText: .common(.no)
            ) {
                KeychainService.shared.removeAll()
                DefaultsService.shared.removeAll()
                NavigationService.loadAuth()
            }
        }

        return profileModule
    }
}

// MARK: - Services
extension MainMenuFlow {
    struct ServicesPayload {
        let user: UserProxy
    }

    static func servicesModule(with payload: ServicesPayload) -> UIViewController {
        ServicesViewController(user: payload.user)
    }
}

// MARK: - Managers
extension MainMenuFlow {
    struct ManagersPayload {
        let userId: String
    }

    static func managersModule(with payload: ManagersPayload) -> UIViewController {
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

    static func settingsModule(with payload: SettingsPayload) -> any SettingsModule {
        SettingsViewController(user: payload.user)
    }
}

// MARK: - Bookings
extension MainMenuFlow {
    struct BookingsPayload {
        let userId: String
    }

    static func bookingsModule(with payload: BookingsPayload) -> UIViewController {
        let interactor = BookingsInteractor(userId: payload.userId)
        return BookingsViewController(interactor: interactor)
    }
}

// MARK: - Cars
extension MainMenuFlow {
    struct CarsPayload {
        let user: UserProxy
    }

    static func carsModule(with payload: CarsPayload) -> UIViewController {
        let interactor = CarsInteractor(user: payload.user)
        let controller = CarsViewController(interactor: interactor)
        return controller
    }
}
