import UIKit

enum UtilsFlow {
    static func connectionLostModule(reconnectionService: ReconnectionService = InfoService()) -> UIViewController {
        let interactor = ConnectionLostInteractor(reconnectionService: reconnectionService)
        let controller = ConnectionLostViewController(interactor: interactor)
        return controller
    }

    static func agreementModule() -> UIViewController {
        AgreementViewController()
    }

    static func splashScreenModule() -> UIViewController {
        SplashScreenViewController()
    }
}
