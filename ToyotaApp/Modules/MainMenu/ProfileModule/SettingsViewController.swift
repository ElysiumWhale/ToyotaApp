import UIKit
import DesignKit

enum SettingsOutput: Hashable {
    case changePhone(_ userId: String)
    case showAgreement
}

protocol SettingsModule: UIViewController, Outputable<SettingsOutput> { }

final class SettingsViewController: BaseViewController, SettingsModule {
    private let phoneLabel = UILabel()
    private let phoneTextField = InputTextField(.toyota)
    private let changeNumberButton = CustomizableButton(.toyotaAction(18))
    private let bottomStack = UIStackView()
    private let agreementButton = CustomizableButton()
    private let companyNameLabel = UILabel()
    private let versionLabel = UILabel()

    private let user: UserProxy

    var output: ParameterClosure<SettingsOutput>?

    init(user: UserProxy, notificator: EventNotificator = .shared) {
        self.user = user

        super.init()

        notificator.add(self, for: .phoneUpdate)
    }

    override func addViews() {
        addDismissRightButton()
        bottomStack.addArrangedSubviews(
            agreementButton,
            companyNameLabel,
            versionLabel
        )

        addSubviews(
            phoneLabel,
            phoneTextField,
            changeNumberButton,
            bottomStack
        )
    }

    override func configureLayout() {
        phoneLabel.edgesToSuperview(
            excluding: .bottom,
            insets: .uniform(20),
            usingSafeArea: true
        )

        phoneTextField.topToBottom(of: phoneLabel, offset: 10)
        phoneTextField.horizontalToSuperview(insets: .horizontal(20))
        phoneTextField.height(45)
        phoneTextField.isUserInteractionEnabled = false

        changeNumberButton.topToBottom(of: phoneTextField, offset: 10)
        changeNumberButton.centerXToSuperview()
        changeNumberButton.size(.toyotaActionS)

        bottomStack.axis = .vertical
        bottomStack.alignment = .center
        bottomStack.edgesToSuperview(
            excluding: .top,
            insets: .uniform(20),
            usingSafeArea: true
        )
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground

        phoneLabel.font = .toyotaType(.book, of: 18)
        phoneLabel.textColor = .appTint(.signatureGray)
        phoneLabel.textAlignment = .center
        phoneLabel.backgroundColor = view.backgroundColor

        agreementButton.setTitleColor(.link, for: .normal)
        agreementButton.titleLabel?.font = .toyotaType(.semibold, of: 15)
        agreementButton.titleLabel?.backgroundColor = view.backgroundColor

        versionLabel.font = .toyotaType(.regular, of: 17)
        versionLabel.textColor = .lightGray
        versionLabel.textAlignment = .center
        versionLabel.backgroundColor = view.backgroundColor
        companyNameLabel.backgroundColor = view.backgroundColor
    }

    override func localize() {
        navigationItem.title = .common(.settings)
        phoneLabel.text = .common(.phoneNumber)
        phoneTextField.text = user.phone
        changeNumberButton.setTitle(.common(.change), for: .normal)
        agreementButton.setTitle(.common(.terms), for: .normal)
        companyNameLabel.text = .common(.alyansPro)
        versionLabel.text = "\(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))"
    }

    override func configureActions() {
        changeNumberButton.addAction { [weak self] in
            self?.changeNumber()
        }

        agreementButton.addAction { [weak self] in
            self?.output?(.showAgreement)
        }
    }

    private func changeNumber() {
        PopUp.displayChoice(
            with: .common(.confirmation),
            description: .question(.changeNumber)
        ) { [self] in
            output?(.changePhone(user.id))
        }
    }
}

// MARK: - ObservesEvents
extension SettingsViewController: ObservesEvents {
    func handle(
        event: EventNotificator.AppEvents,
        notificator: EventNotificator
    ) {
        guard event == .phoneUpdate else {
            return
        }

        DispatchQueue.main.async { [self] in
            phoneTextField.text = user.phone
        }
    }
}
