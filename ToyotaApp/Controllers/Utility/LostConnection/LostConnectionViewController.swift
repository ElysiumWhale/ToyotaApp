import UIKit
import DesignKit

// MARK: - ViewController
final class LostConnectionViewController: BaseViewController {
    private let logoView = UIImageView(image: .toyotaLogo)
    private let textLabel = UILabel()
    private let retryButton = CustomizableButton()
    private let indicator = UIActivityIndicatorView()

    private let interactor: LostConnectionInteractor

    init(interactor: LostConnectionInteractor) {
        self.interactor = interactor

        super.init()
    }

    override func addViews() {
        addSubviews(logoView, textLabel, retryButton, indicator)
    }

    override func configureLayout() {
        logoView.topToSuperview(offset: 75)
        logoView.centerXToSuperview()
        logoView.size(CGSize(width: 128, height: 128))

        textLabel.topToBottom(of: logoView, offset: 20)
        textLabel.centerYToSuperview()
        textLabel.horizontalToSuperview(insets: .horizontal(20))

        retryButton.bottomToSuperview(
            offset: -20,
            usingSafeArea: true
        )
        retryButton.horizontalToSuperview(insets: .horizontal(30))
        retryButton.height(45)
        indicator.center(in: retryButton)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground

        textLabel.font = .toyotaType(.semibold, of: 22)
        textLabel.textAlignment = .center
        textLabel.backgroundColor = view.backgroundColor
        textLabel.numberOfLines = 0

        retryButton.normalColor = .appTint(.secondarySignatureRed)
        retryButton.highlightedColor = .appTint(.dimmedSignatureRed)
        retryButton.titleLabel?.font = .toyotaType(.regular, of: 22)
        retryButton.rounded = true
    }

    override func localize() {
        retryButton.setTitle(.common(.retry), for: .normal)
        textLabel.text = .connectionError
    }

    override func configureActions() {
        retryButton.addTarget(
            self, action: #selector(reconnect), for: .touchUpInside
        )

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
