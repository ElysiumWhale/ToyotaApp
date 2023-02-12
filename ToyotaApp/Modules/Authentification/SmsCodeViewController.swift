import UIKit
import DesignKit

enum SmsCodeModuleOutput: Hashable {
    case successfulCheck(
        _ authScenario: AuthScenario,
        _ context: CheckUserContext?
    )
}

protocol SmsCodeModule: UIViewController, Outputable<SmsCodeModuleOutput> { }

final class SmsCodeViewController: BaseViewController, Loadable, SmsCodeModule {
    private let infoLabel = UILabel()
    private let phoneLabel = UILabel()
    private let codeTextField = InputTextField(.toyota)
    private let errorLabel = UILabel()
    private let codeStack = UIStackView()
    private let sendCodeButton = CustomizableButton(.toyotaAction())

    private let interactor: SmsCodeInteractor

    let loadingView = LoadingView()

    var output: ParameterClosure<SmsCodeModuleOutput>?

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
        codeStack.spacing = 8
        codeStack.horizontalToSuperview(insets: .horizontal(30))
        codeStack.topToSuperview(offset: 200)

        sendCodeButton.horizontalToSuperview(insets: .horizontal(80))
        sendCodeButton.keyboardConstraint = sendCodeButton.bottomToSuperview(offset: -30)
        sendCodeButton.bindToKeyboard()
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        [infoLabel, phoneLabel, errorLabel].forEach {
            $0.backgroundColor = view.backgroundColor
        }

        infoLabel.font = .toyotaType(.semibold, of: 22)
        infoLabel.textColor = .appTint(.signatureGray)
        infoLabel.textAlignment = .center

        phoneLabel.font = .toyotaType(.book, of: 22)
        phoneLabel.textColor = .appTint(.signatureGray)
        phoneLabel.textAlignment = .center

        codeTextField.maxSymbolCount = 4 // future: 6
        codeTextField.keyboardType = .numberPad
        codeTextField.rule = smsRule

        errorLabel.font = .toyotaType(.regular, of: 18)
        errorLabel.textColor = .systemRed
        errorLabel.alpha = .zero
        errorLabel.textAlignment = .center
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
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        // parent == nil means that controller will be popped (backward navigation)
        if parent == nil {
            interactor.deleteTemporaryPhone()
        }
    }

    private func checkCode() {
        guard codeTextField.validate(
            for: .requiredSymbolsCount(4),
            toggleState: true
        ) else {
            errorLabel.fadeIn(0.3)
            return
        }

        sendCodeButton.fadeOut()
        startLoading()
        view.endEditing(true)

        Task {
            switch await interactor.checkCode(code: codeTextField.inputText) {
            case let .success(params):
                stopLoading()
                sendCodeButton.fadeIn()
                resolveNavigation(authType: params.0, context: params.1)
            case let .failure(message):
                stopLoading()
                sendCodeButton.fadeIn()
                PopUp.display(.error(description: message))
            }
        }
    }

    private func resolveNavigation(
        authType: AuthScenario,
        context: CheckUserContext?
    ) {
        switch authType {
        case .register:
            output?(.successfulCheck(authType, context))
        case .changeNumber:
            PopUp.display(.success(description: .common(.phoneChanged)))
            output?(.successfulCheck(authType, nil))
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
