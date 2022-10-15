import UIKit

class MainTabBarController: UITabBarController {

    struct TabConfiguration {
        let tabTitle: String
        let image: UIImage
        let selectedImage: UIImage
        let navTitle: String
    }

    func setControllers(_ configurations: (controller: UIViewController,
                                           tab: TabConfiguration)...) {

        let controllers = configurations.map { config -> UIViewController in
            let navVC = UINavigationController(rootViewController: config.controller)
            navVC.tabBarItem.title = config.tab.tabTitle
            navVC.navigationItem.title = config.tab.navTitle
            navVC.tabBarItem.image = config.tab.image
            navVC.tabBarItem.selectedImage = config.tab.selectedImage
            return navVC
        }

        tabBar.tintColor = .appTint(.secondarySignatureRed)
        setViewControllers(controllers, animated: true)
    }
}
