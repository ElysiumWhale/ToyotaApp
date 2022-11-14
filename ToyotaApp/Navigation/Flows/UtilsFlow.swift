import UIKit

enum UtilsFlow {
    static func connectionLostModule(
        reconnectionService: ReconnectionService = InfoService()
    ) -> UIViewController {
        let interactor = LostConnectionInteractor(
            reconnectionService: reconnectionService
        )
        let controller = LostConnectionViewController(interactor: interactor)
        return controller
    }

    static func agreementModule() -> UIViewController {
        AgreementViewController()
    }

    static func splashScreenModule() -> UIViewController {
        SplashScreenViewController()
    }
}
