import UIKit

enum AuthFlow {
    static let storyboard: UIStoryboard = UIStoryboard(.auth)

    static func authModule(authType: AuthType) -> UIViewController {
        let avc: AuthViewController = storyboard.instantiate(.auth)
        avc.configure(with: authType)
        return avc
    }

    static func codeModule(authType: AuthType, number: String) -> UIViewController {
        let scvc: SmsCodeViewController = storyboard.instantiate(.code)
        scvc.configure(with: authType, and: number)
        return scvc
    }

    static func entryPoint(with controllers: [UIViewController] = []) -> UIViewController {
        let nvc: UINavigationController = storyboard.instantiate(.authNavigation)
        nvc.navigationBar.tintColor = UIColor.appTint(.secondarySignatureRed)
        if controllers.isNotEmpty {
            nvc.setViewControllers(controllers, animated: false)
        }
        return nvc
    }
}
