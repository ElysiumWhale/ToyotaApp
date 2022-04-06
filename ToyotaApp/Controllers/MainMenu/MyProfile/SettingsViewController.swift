import UIKit

final class NewSettingsViewController: InitialazableViewController {
    private let phoneLabel = UILabel()
    private let phoneTextField = InputTextField()
    private let changeNumberButton = CustomizableButton()
    private let bottomStack = UIStackView()
    private let agreementButton = CustomizableButton()
    private let companyNameLabel = UILabel()
    private let versionLabel = UILabel()

    private let user: UserProxy

    init(user: UserProxy) {
        self.user = user

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func addViews() {
        let buttonItem = UIBarButtonItem(title: "Готово")
        buttonItem.action = #selector(customDismiss)
        buttonItem.tintColor = .appTint(.secondarySignatureRed)
        navigationItem.rightBarButtonItem = buttonItem

        bottomStack.addArrangedSubviews(agreementButton,
                                        companyNameLabel,
                                        versionLabel)

        addSubviews(phoneLabel,
                    phoneTextField,
                    changeNumberButton,
                    bottomStack)
    }

    override func configureLayout() {
        phoneLabel.edgesToSuperview(excluding: .bottom,
                                    insets: .uniform(20),
                                    usingSafeArea: true)

        phoneTextField.topToBottom(of: phoneLabel, offset: 10)
        phoneTextField.horizontalToSuperview(insets: .horizontal(20))
        phoneTextField.height(45)
        phoneTextField.isUserInteractionEnabled = false

        changeNumberButton.topToBottom(of: phoneTextField, offset: 10)
        changeNumberButton.centerXToSuperview()
        changeNumberButton.width(160)
        changeNumberButton.height(40)

        bottomStack.axis = .vertical
        bottomStack.alignment = .center
        bottomStack.edgesToSuperview(excluding: .top,
                                     insets: .uniform(20),
                                     usingSafeArea: true)
    }

    override func configureAppearance() {
        view.backgroundColor = .white

        phoneLabel.font = .toyotaType(.book, of: 18)
        phoneLabel.textColor = .appTint(.signatureGray)
        phoneLabel.textAlignment = .center

        phoneTextField.font = .toyotaType(.light, of: 22)
        phoneTextField.backgroundColor = .appTint(.background)
        phoneTextField.textAlignment = .center
        phoneTextField.cornerRadius = 10

        changeNumberButton.highlightedColor = .appTint(.dimmedSignatureRed)
        changeNumberButton.normalColor = .appTint(.secondarySignatureRed)
        changeNumberButton.setTitleColor(.white, for: .normal)
        changeNumberButton.rounded = true

        agreementButton.setTitleColor(.link, for: .normal)
        agreementButton.titleLabel?.font = .toyotaType(.semibold, of: 15)

        versionLabel.font = .toyotaType(.regular, of: 17)
        versionLabel.textColor = .lightGray
        versionLabel.textAlignment = .center
    }

    override func localize() {
        navigationItem.title = "Настройки"
        phoneLabel.text = "Номер телефона"
        phoneTextField.text = user.phone
        changeNumberButton.setTitle("Изменить", for: .normal)
        agreementButton.setTitle("Условия соглашения", for: .normal)
        companyNameLabel.text = "ALYANS PRO, OOO"
        versionLabel.text = "Версия 0.1 alpha"
    }

    override func configureActions() {
        subscribe(on: user)

        changeNumberButton.addAction { [weak self] in
            self?.changeNumber()
        }

        agreementButton.addAction { [weak self] in
            self?.showAgreement()
        }
    }

    private func changeNumber() {
        PopUp.displayChoice(with: .common(.confirmation),
                            description: .question(.changeNumber)) { [self] in
            let module = AuthFlow.authModule(authType: .changeNumber(with: user.notificator))
            navigationController?.pushViewController(module, animated: true)
        }
    }

    private func showAgreement() {
        present(AuthFlow.agreementModule(), animated: true)
    }
}

extension NewSettingsViewController: WithUserInfo {
    func setUser(info: UserProxy) { }
}
