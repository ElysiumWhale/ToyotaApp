import UIKit

protocol NavigationRootHolder<Path> {
    associatedtype Path: Hashable

    var tabsRoots: [Path: UINavigationController] { get }
    var root: UIViewController { get }
}

final class MainTabBarController: UITabBarController,
                                  NavigationRootHolder {

    private(set) var tabsRoots: [Tabs: UINavigationController] = [:]

    var root: UIViewController {
        self
    }

    func setControllersForTabs(
        _ controllersForTabs: (
            controller: UIViewController,
            tab: Tabs
        )...
    ) {

        let controllers = controllersForTabs.map { config -> UIViewController in
            let navVC = UINavigationController(rootViewController: config.controller)
            let tabConfig = config.tab.configuration

            navVC.tabBarItem.title = tabConfig.tabTitle
            navVC.navigationItem.title = tabConfig.navTitle
            navVC.tabBarItem.image = tabConfig.image
            navVC.tabBarItem.selectedImage = tabConfig.selectedImage

            tabsRoots[config.tab] = navVC
            return navVC
        }

        tabBar.tintColor = .appTint(.secondarySignatureRed)
        setViewControllers(controllers, animated: true)
    }
}
