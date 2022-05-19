import UIKit

enum AuthFlow {
    static let storyboard: UIStoryboard = UIStoryboard(.auth)

    static func authModule(authType: AuthType = .register,
                           authService: AuthService = InfoService()) -> UIViewController {
        let interactor = AuthInteractor(type: authType, authService: authService)
        return AuthViewController(interactor: interactor)
    }

    static func codeModule(authType: AuthType, number: String) -> UIViewController {
        let scvc: SmsCodeViewController = storyboard.instantiate(.code)
        scvc.configure(with: authType, and: number)
        return scvc
    }

    static func entryPoint(with controllers: [UIViewController] = []) -> UIViewController {
        let module = authModule().wrappedInNavigation
        module.navigationBar.tintColor = .appTint(.secondarySignatureRed)
        if controllers.isNotEmpty {
            module.setViewControllers(controllers, animated: false)
        }

        return module
    }

    static func agreementModule() -> UIViewController {
        storyboard.instantiate(.agreement)
    }
}
