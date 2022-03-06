import UIKit

enum MainMenuFlow {
    static let storyboard: UIStoryboard = UIStoryboard(.mainMenu)

    static func entryPoint(with user: UserProxy) -> UIViewController {
        let tbvc: UITabBarController = storyboard.instantiate(.mainMenuTabBar)
        tbvc.setUserForChildren(user)
        return tbvc
    }
}

enum UtilsFlow {
    static func connectionLostModule() -> UIViewController {
        let storyboard = UIStoryboard(.main)
        let controller: ConnectionLostViewController = storyboard.instantiate(.connectionLost)
        return controller
    }
}
