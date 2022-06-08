import UIKit

// MARK: - ViewController
final class ConnectionLostViewController: InitialazableViewController {
    private let logoView = UIImageView(image: .toyotaLogo)
    private let connectionTextView = UITextView()
    private let retryButton = CustomizableButton()
    private let indicator = UIActivityIndicatorView()

    private let interactor: ConnectionLostInteractor

    init(interactor: ConnectionLostInteractor) {
        self.interactor = interactor

        super.init()
    }

    override func addViews() {
        addSubviews(logoView, connectionTextView, retryButton, indicator)
    }

    override func configureLayout() {
        logoView.topToSuperview(offset: 75)
        logoView.centerXToSuperview()
        logoView.size(CGSize(width: 128, height: 128))

        connectionTextView.topToBottom(of: logoView, offset: 20)
        connectionTextView.centerYToSuperview()
        connectionTextView.horizontalToSuperview(insets: .horizontal(20))

        retryButton.bottomToSuperview(offset: -20, usingSafeArea: true)
        retryButton.horizontalToSuperview(insets: .horizontal(30))
        retryButton.height(45)
        indicator.center(in: retryButton)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground

        connectionTextView.font = .toyotaType(.semibold, of: 22)
        connectionTextView.textAlignment = .center

        retryButton.normalColor = .appTint(.secondarySignatureRed)
        retryButton.highlightedColor = .appTint(.dimmedSignatureRed)
        retryButton.titleLabel?.font = .toyotaType(.regular, of: 22)
        retryButton.rounded = true
    }

    override func localize() {
        retryButton.setTitle(.common(.retry), for: .normal)
        connectionTextView.text = .connectionError
    }

    override func configureActions() {
        retryButton.addTarget(self, action: #selector(reconnect), for: .touchUpInside)

        interactor.onSuccess = { context in
            NavigationService.resolveNavigation(with: context) {
                NavigationService.loadAuth()
            }
        }

        interactor.onError = { [weak self] errorResponse in
            switch errorResponse.errorCode {
                case .lostConnection:
                    self?.displayError()
                default:
                    NavigationService.loadAuth(with: errorResponse.message ?? .error(.errorWhileAuth))
            }
        }
    }

    @objc private func reconnect() {
        retryButton.fadeOut()
        indicator.startAnimating()
        interactor.reconnect()
    }

    private func displayError() {
        indicator.stopAnimating()
        retryButton.fadeIn()
        PopUp.display(.error(description: .error(.stillNoConnection)))
    }
}

extension String {
    static var connectionError: String {
        """
        Что-то пошло не так...
        Проверьте соединение с интернетом и повторите попытку входа
        """
    }
}

// MARK: - Interactor
class ConnectionLostInteractor {
    private let reconnectionService: ReconnectionService

    var onSuccess: ParameterClosure<CheckUserContext>?
    var onError: ParameterClosure<ErrorResponse>?

    private lazy var requestHandler = RequestHandler<CheckUserOrSmsCodeResponse>()
        .observe(on: .main)
        .bind { [weak self] response in
            KeychainManager.set(SecretKey(response.secretKey))
            self?.onSuccess?(CheckUserContext(response: response))
        } onFailure: { [weak self] errorResponse in
            self?.onError?(errorResponse)
        }

    init(reconnectionService: ReconnectionService) {
        self.reconnectionService = reconnectionService
    }

    func reconnect() {
        guard let userId = KeychainManager<UserId>.get()?.value,
              let secretKey = KeychainManager<SecretKey>.get()?.value else {
            onError?(ErrorResponse(code: .corruptedData, message: nil))
            return
        }

        let body = CheckUserBody(userId: userId, secret: secretKey, brandId: Brand.Toyota)
        reconnectionService.checkUser(with: body, handler: requestHandler)
    }
}
