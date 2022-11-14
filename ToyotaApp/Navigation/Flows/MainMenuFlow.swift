import UIKit

private typealias TabConfiguration = MainTabBarController.TabConfiguration

enum MainMenuFlow {
    static func entryPoint(for user: UserProxy) -> UIViewController {
        let tbvc = MainTabBarController()
        tbvc.setControllers(newsConfiguration,
                            servicesConfiguration(with: user),
                            profileConfiguration(with: user))
        return tbvc
    }

    static func newsModule() -> UIViewController {
        NewsViewController()
    }

    static func servicesModule(with user: UserProxy) -> UIViewController {
        ServicesViewController(user: user)
    }

    static func profileModule(with user: UserProxy) -> UIViewController {
        ProfileViewController(interactor: .init(user: user))
    }

    static func chatModule() -> UIViewController {
        let vc = ChatViewController()
        vc.hidesBottomBarWhenPushed = true
        return vc
    }

    static func bookingsModule() -> UIViewController {
        BookingsViewController(interactor: .init())
    }

    static func settingsModule(user: UserProxy) -> UIViewController {
        SettingsViewController(user: user)
    }

    static func managersModule(user: UserProxy) -> UIViewController {
        ManagersViewController(interactor: .init(user: user))
    }

    static func carsModule(user: UserProxy) -> UIViewController {
        CarsViewController(interactor: .init(user: user))
    }
}

// MARK: - Configurations
private extension MainMenuFlow {
    static var newsConfiguration: (UIViewController, TabConfiguration) {
        let tabConfig = TabConfiguration(
            tabTitle: .common(.offers),
            image: .newspaper,
            selectedImage: .fillNewspaper,
            navTitle: .common(.offers)
        )
        return (newsModule(), tabConfig)
    }
    
    static func servicesConfiguration(
        with user: UserProxy
    ) -> (UIViewController, TabConfiguration) {
        let tabConfig = TabConfiguration(
            tabTitle: .common(.services),
            image: .bookmark,
            selectedImage: .fillBookmark,
            navTitle: .common(.services)
        )
        return (servicesModule(with: user), tabConfig)
    }
    
    static func profileConfiguration(
        with user: UserProxy
    ) -> (UIViewController, TabConfiguration) {
        let tabConfig = TabConfiguration(
            tabTitle: .common(.profile),
            image: .person,
            selectedImage: .fillPerson,
            navTitle: .common(.profile)
        )
        return (profileModule(with: user), tabConfig)
    }
}
