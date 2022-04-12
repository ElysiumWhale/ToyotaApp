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

enum UtilsFlow {
    static func connectionLostModule() -> UIViewController {
        let storyboard = UIStoryboard(.main)
        let controller: ConnectionLostViewController = storyboard.instantiate(.connectionLost)
        return controller
    }
}
