import UIKit

// MARK: - View
class ConnectionLostViewController: UIViewController {
    @IBOutlet private var retryButton: CustomizableButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!

    private lazy var interactor: ConnectionLostInteractor = {
        ConnectionLostInteractor(view: self)
    }()

    @IBAction func reconnect(sender: UIButton) {
        retryButton.isHidden = true
        indicator.startAnimating()
        interactor.reconnect()
    }

    func displayError() {
        indicator.stopAnimating()
        retryButton.isHidden = false
        PopUp.display(.error(description: .error(.stillNoConnection)))
    }
}

// MARK: - Interactor
class ConnectionLostInteractor {
    weak var view: ConnectionLostViewController?

    private lazy var requestHandler: RequestHandler<CheckUserOrSmsCodeResponse> =
        .init { response in
            KeychainManager.set(SecretKey(response.secretKey))
            NavigationService.resolveNavigation(with: CheckUserContext(response: response)) {
                NavigationService.loadAuth()
            }
        } onFailure: { [weak self] error in
            switch error.errorCode {
                case .lostConnection: self?.view?.displayError()
                default: NavigationService.loadAuth(with: error.message ?? .error(.errorWhileAuth))
            }
        }

    init(view: ConnectionLostViewController) {
        self.view = view
    }

    func reconnect() {
        guard let userId = KeychainManager<UserId>.get()?.value,
              let secretKey = KeychainManager<SecretKey>.get()?.value else {
            NavigationService.loadAuth()
            return
        }

        NetworkService.makeRequest(page: .start(.checkUser),
                                   params: [(.auth(.userId), userId),
                                            (.auth(.brandId), Brand.Toyota),
                                            (.auth(.secretKey), secretKey)],
                                   handler: requestHandler)
    }
}
