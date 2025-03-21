import UIKit
import DesignKit

enum EndRegistrationOutput: Hashable, CaseIterable {
    case registerDidEnd
}

protocol EndRegistrationModule: UIViewController, Outputable<EndRegistrationOutput> { }

final class EndRegistrationViewController: BaseViewController,
                                           EndRegistrationModule {

    private let logoImageView = UIImageView(image: .toyotaLogo)
    private let infoStack = UIStackView()
    private let thanksLabel = UILabel()
    private let infoLabel = UILabel()
    private let wishesLabel = UILabel()
    private let actionButton = CustomizableButton(.toyotaAction())

    var output: ParameterClosure<EndRegistrationOutput>?

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
        actionButton.size(.toyotaActionL)
        actionButton.bottomToSuperview(offset: -16, usingSafeArea: true)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        thanksLabel.font = .toyotaType(.regular, of: 36)
        infoLabel.font = .toyotaType(.regular, of: 22)
        wishesLabel.font = .toyotaType(.regular, of: 22)

        for label in [thanksLabel, infoLabel, wishesLabel] {
            label.textColor = .appTint(.signatureGray)
            label.numberOfLines = .zero
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .center
            label.backgroundColor = view.backgroundColor
        }
    }

    override func localize() {
        thanksLabel.text = .common(.thanksForRegister)
        infoLabel.text = .common(.appFeatures)
        wishesLabel.text = .common(.wishes)
        actionButton.setTitle(.common(.toMainMenu), for: .normal)
    }

    override func configureActions() {
        actionButton.addAction { [weak self] in
            self?.output?(.registerDidEnd)
        }
    }
}
