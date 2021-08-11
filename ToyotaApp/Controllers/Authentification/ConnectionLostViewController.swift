import UIKit

class ConnectionLostViewController: UIViewController {
// MARK: - View
    var controller: ConnectionLostController?
    
    @IBOutlet private var retryButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        controller = ConnectionLostController(view: self)
    }
    
    @IBAction func reconnect(sender: UIButton) {
        retryButton.isHidden = true
        indicator.startAnimating()
        controller?.reconnect()
    }
    
    func displayError() {
        DispatchQueue.main.async { [weak self] in
            self?.indicator.stopAnimating()
            self?.retryButton.isHidden = false
            PopUp.display(.error(description: CommonText.stillNoConnection))
        }
    }
}

// MARK: - Controller
class ConnectionLostController {
    weak var view: ConnectionLostViewController?
    
    init(view: ConnectionLostViewController) {
        self.view = view
    }
    
    func reconnect() {
        guard let userId = KeychainManager.get(UserId.self)?.id,
              let secretKey = KeychainManager.get(SecretKey.self)?.secret else {
            NavigationService.loadAuth()
            return
        }
        
        NetworkService.shared.makePostRequest(page: RequestPath.Start.checkUser, params:
            [URLQueryItem(name: RequestKeys.Auth.userId, value: userId),
             URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.Toyota),
             URLQueryItem(name: RequestKeys.Auth.secretKey, value: secretKey)],
        completion: completion)
    }
    
    private func completion(for response: Result<CheckUserOrSmsCodeResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                KeychainManager.set(SecretKey(data.secretKey))
                NavigationService.resolveNavigation(with: CheckUserContext(response: data),
                                                    fallbackCompletion: NavigationService.loadAuth)
            case .failure(let error):
                switch error.code {
                    case NetworkErrors.lostConnection.rawValue: view?.displayError()
                    default: NavigationService.loadAuth(with: error.message ?? CommonText.errorWhileAuth)
                }
        }
    }
}
