import UIKit

final class AuthViewController: BaseViewController, Loadable {
    private let logo = UIImageView(image: .toyotaLogo)

    private let infoStack = UIStackView()
    private let informationLabel = UILabel()
    private let phoneNumber = PhoneTextField()
    private let incorrectLabel = UILabel()

    private let agreementStack = UIStackView()
    private let agreementLabel = UILabel()
    private let agreementButton = UIButton()
    private let sendPhoneButton = CustomizableButton()

    private let interactor: AuthInteractor

    let loadingView = LoadingView()

    var isLoading: Bool = false

    init(interactor: AuthInteractor) {
        self.interactor = interactor
        super.init()
    }

    // MARK: - Overrides
    override func addViews() {
        infoStack.addArrangedSubviews(informationLabel, phoneNumber, incorrectLabel)
        agreementStack.addArrangedSubviews(agreementLabel, agreementButton)
        addSubviews(logo, infoStack, agreementStack, sendPhoneButton)
    }

    override func configureLayout() {
        view.hideKeyboardWhenSwipedDown()

        logo.size(.init(width: 128, height: 128))
        logo.aspectRatio(1)
        logo.centerXToSuperview()
        logo.topToSuperview(offset: 20, usingSafeArea: true)
        logo.bottomToTop(of: infoStack, offset: -18)

        infoStack.axis = .vertical
        infoStack.horizontalToSuperview(insets: .horizontal(30))
        infoStack.centerXToSuperview()
        phoneNumber.height(50)
        phoneNumber.clearButtonMode = .always

        agreementButton.height(22)
        agreementStack.axis = .vertical
        agreementStack.horizontalToSuperview(insets: .horizontal(75))
        agreementStack.bottomToSuperview(offset: -100)

        sendPhoneButton.horizontalToSuperview(insets: .horizontal(80))
        sendPhoneButton.keyboardConstraint = sendPhoneButton.bottomToSuperview(offset: -30)
        sendPhoneButton.bindToKeyboard()
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        configureNavBarAppearance(font: nil)

        informationLabel.font = .toyotaType(.semibold, of: 22)
        informationLabel.textColor = .appTint(.signatureGray)
        informationLabel.textAlignment = .center
        phoneNumber.font = .toyotaType(.light, of: 22)
        phoneNumber.textAlignment = .center
        phoneNumber.minimumFontSize = 17
        phoneNumber.adjustsFontSizeToFitWidth = true
        phoneNumber.textColor = .appTint(.signatureGray)
        phoneNumber.tintColor = .appTint(.secondarySignatureRed)
        phoneNumber.backgroundColor = .appTint(.background)
        phoneNumber.keyboardType = .numberPad
        incorrectLabel.font = .toyotaType(.regular, of: 18)
        incorrectLabel.textAlignment = .center
        incorrectLabel.textColor = .systemRed
        incorrectLabel.alpha = 0

        agreementLabel.font = .toyotaType(.regular, of: 14)
        agreementLabel.textAlignment = .center
        agreementLabel.textColor = .appTint(.signatureGray)
        agreementButton.titleLabel?.font = .toyotaType(.semibold, of: 15)
        agreementButton.setTitleColor(.link, for: .normal)

        sendPhoneButton.titleLabel?.font = .toyotaType(.regular, of: 22)
        sendPhoneButton.setTitleColor(.white, for: .normal)
        sendPhoneButton.normalColor = .appTint(.secondarySignatureRed)
        sendPhoneButton.highlightedColor = .appTint(.dimmedSignatureRed)
        sendPhoneButton.rounded = true
    }

    override func localize() {
        informationLabel.text = .common(.accountEntering)
        phoneNumber.placeholder = .common(.phoneNumber)
        phoneNumber.countryPrefix = .ru
        incorrectLabel.text = .error(.wrongPhoneEntered)
        agreementLabel.text = .common(.acceptWhileRegister)
        agreementButton.setTitle(.common(.terms).lowercased(), for: .normal)
        sendPhoneButton.setTitle(.common(.next), for: .normal)

        if case .changeNumber = interactor.type {
            informationLabel.text = .common(.enterNewNumber)
            agreementStack.isHidden = true
        } else {
            setBackButtonTitle(.common(.phoneEntering))
        }
    }

    override func configureActions() {
        phoneNumber.addTarget(
            self,
            action: #selector(phoneDidChange),
            for: .editingChanged
        )
        sendPhoneButton.addTarget(
            self,
            action: #selector(sendPhoneDidPress),
            for: .touchUpInside
        )
        agreementButton.addTarget(
            self,
            action: #selector(openAgreement),
            for: .touchUpInside
        )

        interactor.onSuccess = { [weak self] in
            self?.handle(isSuccess: true)
        }

        interactor.onFailure = { [weak self] errorMessage in
            self?.handle(isSuccess: false)
            PopUp.display(.error(description: errorMessage))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        sendPhoneButton.fadeIn()
    }

    // MARK: - Private methods
    @objc private func phoneDidChange() {
        incorrectLabel.fadeOut(0.3)
        phoneNumber.toggle(state: .normal)
    }

    @objc private func sendPhoneDidPress() {
        guard let phone = phoneNumber.validPhone else {
            phoneNumber.toggle(state: .error)
            incorrectLabel.fadeIn(0.3)
            return
        }

        sendPhoneButton.fadeOut()
        startLoading()
        view.endEditing(true)

        interactor.sendPhone(phone)
    }

    @objc private func openAgreement() {
        present(UtilsFlow.agreementModule().wrappedInNavigation,
                animated: true)
    }

    private func handle(isSuccess: Bool) {
        stopLoading()
        sendPhoneButton.fadeIn()

        guard isSuccess else {
            return
        }
        
        let vc = AuthFlow.codeModule(
            phone: phoneNumber.validPhone!,
            authType: interactor.type
        )
        navigationController?.pushViewController(vc, animated: true)
    }
}
