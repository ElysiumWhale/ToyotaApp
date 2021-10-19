import UIKit

// MARK: - View
class ConnectionLostViewController: UIViewController {
    @IBOutlet private var retryButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!

    private lazy var controller: ConnectionLostController = {
        ConnectionLostController(view: self)
    }()

    @IBAction func reconnect(sender: UIButton) {
        retryButton.isHidden = true
        indicator.startAnimating()
        controller.reconnect()
    }
    
    func displayError() {
        DispatchQueue.main.async { [weak self] in
            self?.indicator.stopAnimating()
            self?.retryButton.isHidden = false
            PopUp.display(.error(description: .error(.stillNoConnection)))
        }
    }
}

// MARK: - Controller
class ConnectionLostController {
    private(set) weak var view: ConnectionLostViewController?
    
    private lazy var requestHandler: RequestHandler<CheckUserOrSmsCodeResponse> = {
        let handler = RequestHandler<CheckUserOrSmsCodeResponse>()
        handler.onSuccess = { [weak self] data in
            KeychainManager.set(SecretKey(data.secretKey))
            if self == nil { return }
            NavigationService.resolveNavigation(with: CheckUserContext(response: data)) {
                NavigationService.loadAuth()
            }
        }
        
        handler.onFailure = { [weak self] error in
            switch error.errorCode {
                case .lostConnection: self?.view?.displayError()
                default: NavigationService.loadAuth(with: error.message ?? .error(.errorWhileAuth))
            }
        }
        return handler
    }()
    
    init(view: ConnectionLostViewController) {
        self.view = view
    }
    
    func reconnect() {
        guard let userId = KeychainManager<UserId>.get()?.id,
              let secretKey = KeychainManager<SecretKey>.get()?.secret else {
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
