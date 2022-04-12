import UIKit

private typealias TabConfiguration = MainTabBarController.TabConfiguration

enum MainMenuFlow {
    static let storyboard: UIStoryboard = UIStoryboard(.mainMenu)

    static func entryPoint(with user: UserProxy) -> UIViewController {
        let tbvc: UITabBarController = storyboard.instantiate(.mainMenuTabBar)
        tbvc.setUserForChildren(user)
        return tbvc
    }

    static func entryPoint(for user: UserProxy) -> UIViewController {
        let tbvc = MainTabBarController()
        return tbvc
    }

    static func newsModule() -> UIViewController {
        let newsVC: NewsViewController = storyboard.instantiate(.news)
        return newsVC
    }

    static func servicesModule(with user: UserProxy) -> UIViewController {
        let servicesVC: ServicesViewController = storyboard.instantiate(.services)
        servicesVC.setUser(info: user)
        return servicesVC
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
