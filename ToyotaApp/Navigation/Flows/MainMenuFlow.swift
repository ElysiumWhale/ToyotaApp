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
        let profileVC: MyProfileViewController = UIStoryboard(.myProfile).instantiate(.myProfile)
        profileVC.setUser(info: user)
        return profileVC
    }
}

// MARK: - Configurations
extension MainMenuFlow {
    private static var newsConfiguration: (UIViewController, TabConfiguration) {
        let tabConfig = TabConfiguration(tabTitle: .common(.offers),
                                         image: .newspaper,
                                         selectedImage: .fillNewspaper,
                                         navTitle: .common(.offers))
        return (newsModule(), tabConfig)
    }

    private static func servicesConfiguration(with user: UserProxy) -> (UIViewController, TabConfiguration) {
        let tabConfig = TabConfiguration(tabTitle: .common(.services),
                                         image: .bookmark,
                                         selectedImage: .fillBookmark,
                                         navTitle: .common(.services))
        return (servicesModule(with: user), tabConfig)
    }

    private static func profileConfiguration(with user: UserProxy) -> (UIViewController, TabConfiguration) {
        let tabConfig = TabConfiguration(tabTitle: .common(.profile),
                                         image: .person,
                                         selectedImage: .fillPerson,
                                         navTitle: .common(.profile))
        return (profileModule(with: user), tabConfig)
    }
}
