import UIKit

enum AuthScenario: Equatable {
    case register
    case changeNumber(userId: String)
}

@MainActor
enum AuthFlow {
    static func authModule(
        authType: AuthScenario = .register,
        authService: IRegistrationService = NewInfoService()
    ) -> UIViewController {
        let interactor = AuthInteractor(type: authType, authService: authService)
        return AuthViewController(interactor: interactor)
    }

    static func codeModule(
        phone: String,
        authType: AuthScenario = .register,
        authService: IRegistrationService = NewInfoService()
    ) -> UIViewController {
        let interactor = SmsCodeInteractor(
            type: authType, phone: phone, authService: authService
        )
        return SmsCodeViewController(interactor: interactor)
    }

    static func entryPoint(
        with controllers: [UIViewController] = []
    ) -> UIViewController {
        let module = authModule().wrappedInNavigation
        module.navigationBar.tintColor = .appTint(.secondarySignatureRed)
        if controllers.isNotEmpty {
            module.setViewControllers(controllers, animated: false)
        }

        return module
    }
}
