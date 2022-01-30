import UIKit

enum MainMenuFlow {
    static let storyboard: UIStoryboard = UIStoryboard(.mainMenu)

    static func entryPoint(with user: UserProxy) -> UIViewController {
        let tbvc: UITabBarController = storyboard.instantiate(.mainMenuTabBar)
        tbvc.setUserForChildren(user)
        return tbvc
    }
}
