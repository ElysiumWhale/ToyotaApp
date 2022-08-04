import UIKit

final class EndRegistrationViewController: BaseViewController {

    private let logoImageView = UIImageView(image: .toyotaLogo)
    private let infoStack = UIStackView()
    private let thanksLabel = UILabel()
    private let infoLabel = UILabel()
    private let wishesLabel = UILabel()
    private let actionButton = CustomizableButton()

    override func addViews() {
        addSubviews(logoImageView, infoStack, actionButton)
        infoStack.addArrangedSubviews(thanksLabel, infoLabel, wishesLabel)
    }

    override func configureLayout() {
        infoStack.axis = .vertical
        infoStack.spacing = 12

        logoImageView.size(.init(width: 128, height: 128))
        logoImageView.topToSuperview(offset: 45, usingSafeArea: true)
        logoImageView.centerXToSuperview()

        infoStack.topToBottom(of: logoImageView, offset: 5)
        infoStack.horizontalToSuperview(insets: .horizontal(20))

        actionButton.centerXToSuperview()
        actionButton.size(.init(width: 245, height: 43))
        actionButton.bottomToSuperview(offset: -16, usingSafeArea: true)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        thanksLabel.font = .toyotaType(.regular, of: 36)
        infoLabel.font = .toyotaType(.regular, of: 22)
        wishesLabel.font = .toyotaType(.regular, of: 22)

        [thanksLabel, infoLabel, wishesLabel].forEach {
            $0.textColor = .appTint(.signatureGray)
            $0.numberOfLines = .zero
            $0.lineBreakMode = .byWordWrapping
            $0.textAlignment = .center
        }

        actionButton.rounded = true
        actionButton.titleLabel?.font = .toyotaType(.regular, of: 22)
        actionButton.normalColor = .appTint(.secondarySignatureRed)
        actionButton.highlightedColor = .appTint(.dimmedSignatureRed)
    }

    override func localize() {
        thanksLabel.text = .common(.thanksForRegister)
        infoLabel.text = .common(.appFeatures)
        wishesLabel.text = .common(.wishes)
        actionButton.setTitle(.common(.toMainMenu), for: .normal)
    }

    override func configureActions() {
        actionButton.addAction {
            NavigationService.loadMain()
        }
    }
}
