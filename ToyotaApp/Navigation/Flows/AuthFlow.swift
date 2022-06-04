import UIKit

enum AuthFlow {
    static func authModule(authType: AuthType = .register,
                           authService: AuthService = InfoService()) -> UIViewController {
        let interactor = AuthInteractor(type: authType, authService: authService)
        return AuthViewController(interactor: interactor)
    }

    static func codeModule(phone: String,
                           authType: AuthType = .register,
                           authService: AuthService = InfoService()) -> UIViewController {
        let interactor = SmsCodeInteractor(type: authType, phone: phone, authService: authService)
        return SmsCodeViewController(interactor: interactor)
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
        AgreementViewController()
    }
}
