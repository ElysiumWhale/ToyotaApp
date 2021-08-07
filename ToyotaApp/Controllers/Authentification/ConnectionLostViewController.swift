import UIKit

class ConnectionLostViewController: UIViewController {
    @IBOutlet private var retryButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func reconnect(sender: UIButton) {
        retryButton.isHidden = true
        indicator.startAnimating()
        
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
                NavigationService.resolveNavigation(with: data, fallbackCompletion: NavigationService.loadAuth)
            case .failure(let error):
                switch error.code {
                    case NetworkErrors.lostConnection.rawValue:
                        DispatchQueue.main.async { [self] in
                            indicator.stopAnimating()
                            retryButton.isHidden = false
                            displayError(with: "Соединение с интернетом все еще отсутствует")
                        }
                    default:
                        NavigationService.loadAuth(with: error.message ?? "При входе произошла ошибка, войдите повторно")
                }
        }
    }
}
