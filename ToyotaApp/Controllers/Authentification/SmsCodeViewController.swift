import UIKit

final class SmsCodeViewController: BaseViewController, Loadable {
    private let infoLabel = UILabel()
    private let phoneLabel = UILabel()
    private let codeTextField = InputTextField()
    private let errorLabel = UILabel()
    private let codeStack = UIStackView()
    private let sendCodeButton = CustomizableButton()

    private let interactor: SmsCodeInteractor

    let loadingView = LoadingView()

    var isLoading: Bool = false

    init(interactor: SmsCodeInteractor) {
        self.interactor = interactor

        super.init()
    }

    override func addViews() {
        codeStack.addArrangedSubviews(
            infoLabel,
            phoneLabel,
            codeTextField,
            errorLabel
        )
        addSubviews(codeStack, sendCodeButton)
    }

    override func configureLayout() {
        view.hideKeyboardWhenSwipedDown()

        codeTextField.height(50)

        codeStack.axis = .vertical
        codeStack.alignment = .fill
        codeStack.horizontalToSuperview(insets: .horizontal(30))
        codeStack.topToSuperview(offset: 200)

        sendCodeButton.horizontalToSuperview(insets: .horizontal(80))
        sendCodeButton.keyboardConstraint = sendCodeButton.bottomToSuperview(offset: -30)
        sendCodeButton.bindToKeyboard()
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground

        infoLabel.font = .toyotaType(.semibold, of: 22)
        infoLabel.textColor = .appTint(.signatureGray)
        infoLabel.textAlignment = .center

        phoneLabel.font = .toyotaType(.book, of: 22)
        phoneLabel.textColor = .appTint(.signatureGray)
        phoneLabel.textAlignment = .center

        codeTextField.font = .toyotaType(.light, of: 22)
        codeTextField.textColor = .appTint(.signatureGray)
        codeTextField.tintColor = .appTint(.secondarySignatureRed)
        codeTextField.backgroundColor = .appTint(.background)
        codeTextField.maxSymbolCount = 4 // future: 6
        codeTextField.textAlignment = .center
        codeTextField.cornerRadius = 10
        codeTextField.keyboardType = .numberPad
        codeTextField.rule = smsRule

        errorLabel.font = .toyotaType(.regular, of: 18)
        errorLabel.textColor = .systemRed
        errorLabel.alpha = .zero
        errorLabel.textAlignment = .center

        sendCodeButton.titleLabel?.font = .toyotaType(.regular, of: 22)
        sendCodeButton.setTitleColor(.white, for: .normal)
        sendCodeButton.normalColor = .appTint(.secondarySignatureRed)
        sendCodeButton.highlightedColor = .appTint(.dimmedSignatureRed)
        sendCodeButton.rounded = true
    }

    override func localize() {
        infoLabel.text = .common(.enterCodeFromSmsFor)
        phoneLabel.text = interactor.phone
        codeTextField.placeholder = .common(.codeFromSms)
        sendCodeButton.setTitle(.common(.next), for: .normal)
        errorLabel.text = .error(.wrongCodeEntered)

        if interactor.type != .register {
            setBackButtonTitle(.common(.phoneEntering))
        }
    }

    override func configureActions() {
        sendCodeButton.addAction { [weak self] in
            self?.checkCode()
        }

        interactor.onSuccess = { [weak self] params in
            self?.stopLoading()
            self?.sendCodeButton.fadeIn()
            self?.resolveNavigation(authType: params.0, context: params.1)
        }

        interactor.onError = { [weak self] errorMessage in
            self?.stopLoading()
            self?.sendCodeButton.fadeIn()
            PopUp.display(.error(description: errorMessage))
        }
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        // parent == nil means that controller will be popped (backward navigation)
        if parent == nil {
            interactor.deleteTemporaryPhone()
        }
    }

    private func checkCode() {
        guard let code = codeTextField.text,
              codeTextField.validate(for: .requiredSymbolsCount(4),
                                     toggleState: true) else {
            errorLabel.fadeIn(0.3)
            return
        }

        sendCodeButton.fadeOut()
        startLoading()
        view.endEditing(true)

        interactor.checkCode(code: code)
    }

    private func resolveNavigation(authType: AuthScenario, context: CheckUserContext?) {
        switch authType {
        case .register:
            guard let context = context else {
                return
            }

            NavigationService.resolveNavigation(with: context) {
                NavigationService.loadRegister(.error(message: .error(.serverBadResponse)))
            }
        case .changeNumber:
            PopUp.display(.success(description: .common(.phoneChanged)))
            navigationController?.popToRootViewController(animated: true)
        }
    }
}

private extension SmsCodeViewController {
    var smsRule: ValidationRule {
        ValidationRule { [weak self] _ in
            self?.errorLabel.fadeOut(0.3)

            return true
        }
    }
}
