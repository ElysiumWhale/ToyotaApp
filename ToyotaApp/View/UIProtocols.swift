import Foundation
import UIKit

enum Storyboards: String {
    case main = "Main"
    case launchScreen = "LaunchScreen"
    case auth = "Authentification"
    case register = "FirstLaunchRegistration"
    case mainMenu = "MainMenu"
}

protocol Storyboarded {
    static var storyBoard: Storyboards { get }
    static func instatinate() -> Self
    static func instatinate(from storyboard: Storyboards) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantinate() -> Self {
        let name = String(describing: self)
        let viewControllerIdentifier = name.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: storyBoard.rawValue, bundle: Bundle.main)
        guard let result = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? Self else { fatalError() }
        return result
    }
    
    static func instantinate(from storyboard: Storyboards) { }
}
