import UIKit

enum UtilsFlow {
    static func connectionLostModule() -> UIViewController {
        let storyboard = UIStoryboard(.main)
        let controller: ConnectionLostViewController = storyboard.instantiate(.connectionLost)
        return controller
    }
}
