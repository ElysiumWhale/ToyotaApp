import UIKit
import DesignKit
import ComposableArchitecture
import Combine

final class SmsCodeViewController: BaseViewController, Loadable {
    private let infoLabel = UILabel()
    private let phoneLabel = UILabel()
    private let codeTextField = InputTextField(.toyota)
    private let errorLabel = UILabel()
    private let codeStack = UIStackView()
    private let sendCodeButton = CustomizableButton(.toyotaAction())
    let loadingView = LoadingView()

    private let viewStore: ViewStoreOf<SmsCodeFeature>

    private var cancellables: Set<AnyCancellable> = []

    init(store: StoreOf<SmsCodeFeature>) {
        self.viewStore = ViewStore(store)

        super.init()

        setupSubscriptions()
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

        errorLabel.font = .toyotaType(.regular, of: 18)
        errorLabel.textColor = .systemRed
        errorLabel.alpha = .zero
        errorLabel.textAlignment = .center
    }

    override func localize() {
        infoLabel.text = .common(.enterCodeFromSmsFor)
        phoneLabel.text = viewStore.phone
        codeTextField.placeholder = .common(.codeFromSms)
        sendCodeButton.setTitle(.common(.next), for: .normal)
        errorLabel.text = .error(.wrongCodeEntered)

        if case .changeNumber = viewStore.scenario {
            setBackButtonTitle(.common(.phoneEntering))
        }
    }

    override func configureActions() {
        codeTextField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )

        sendCodeButton.addAction { [weak self] in
            let code = self?.codeTextField.text ?? .empty
            self?.viewStore.send(.checkCode(code))
        }
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        // parent == nil means that controller will be popped (backward navigation)
        if parent == nil {
            viewStore.send(.deleteTemporaryPhone)
        }
    }

    private func setupSubscriptions() {
        viewStore.publisher.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                if $0 {
                    startLoading()
                    view.endEditing(true)
                } else {
                    stopLoading()
                }
                sendCodeButton.fade($0 ? .out() : .in())
            }
            .store(in: &cancellables)

        viewStore.publisher.isValid
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                errorLabel.fade($0 ? .out(0.3) : .in(0.3) )
                codeTextField.toggle(state: $0 ? .normal : .error)
            }
            .store(in: &cancellables)

        viewStore.publisher.popupMessage
            .compactMap { $0 }
            .sink { PopUp.display(.error($0)) }
            .store(in: &cancellables)
    }

    @objc private func textDidChange() {
        viewStore.send(.codeDidChange(codeTextField.inputText))
    }
}
