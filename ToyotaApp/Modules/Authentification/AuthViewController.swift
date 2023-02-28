import UIKit
import DesignKit
import ComposableArchitecture
import Combine

final class AuthViewController: BaseViewController, Loadable {
    private let viewStore: ViewStoreOf<AuthFeature>

    private let logo = UIImageView(image: .toyotaLogo)

    private let infoStack = UIStackView()
    private let informationLabel = UILabel()
    private let phoneNumber = PhoneTextField()
    private let incorrectLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        return label
    }()

    private let agreementStack = UIStackView()
    private let agreementLabel = UILabel()
    private let agreementButton = UIButton()
    private let sendPhoneButton = CustomizableButton(.toyotaAction())

    private var cancellables: Set<AnyCancellable> = []

    let loadingView = LoadingView()

    init(store: StoreOf<AuthFeature>) {
        self.viewStore = ViewStore(store)

        super.init()

        setupSubscriptions()
    }

    // MARK: - Overrides
    override func addViews() {
        infoStack.addArrangedSubviews(informationLabel, phoneNumber, incorrectLabel)
        agreementStack.addArrangedSubviews(agreementLabel, agreementButton)
        addSubviews(logo, infoStack, agreementStack, sendPhoneButton)
    }

    override func configureLayout() {
        logo.size(.init(width: 128, height: 128))
        logo.aspectRatio(1)
        logo.centerXToSuperview()
        logo.topToSuperview(offset: 20, usingSafeArea: true)
        logo.bottomToTop(of: infoStack, offset: -18)

        infoStack.axis = .vertical
        infoStack.horizontalToSuperview(insets: .horizontal(30))
        infoStack.centerXToSuperview()
        infoStack.spacing = 8
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
        informationLabel.font = .toyotaType(.semibold, of: 22)
        informationLabel.textColor = .appTint(.signatureGray)
        informationLabel.textAlignment = .center
        informationLabel.backgroundColor = view.backgroundColor
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
    }

    override func localize() {
        informationLabel.text = .common(.accountEntering)
        phoneNumber.placeholder = .common(.phoneNumber)
        phoneNumber.countryPrefix = .ru
        incorrectLabel.text = .error(.wrongPhoneEntered)
        agreementLabel.text = .common(.acceptWhileRegister)
        agreementButton.setTitle(.common(.terms).lowercased(), for: .normal)
        sendPhoneButton.setTitle(.common(.next), for: .normal)

        switch viewStore.scenario {
        case .changeNumber:
            informationLabel.text = .common(.enterNewNumber)
            agreementStack.isHidden = true
        case .register:
            setBackButtonTitle(.common(.phoneEntering))
        }
    }

    override func configureActions() {
        view.hideKeyboardWhenSwipedDown()

        sendPhoneButton.addAction { [weak self] in
            let validPhone = self?.phoneNumber.validPhone
            self?.viewStore.send(.sendButtonDidPress(validPhone))
        }

        phoneNumber.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )

        agreementButton.addAction { [weak viewStore] in
            viewStore?.send(.showAgreement)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        sendPhoneButton.fadeIn()
    }

    // MARK: - Private methods
    private func setupSubscriptions() {
        viewStore.publisher.isValid
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                phoneNumber.toggle(state: $0 ? .normal : .error)
                if $0 {
                    incorrectLabel.fadeOut(0.3)
                } else {
                    incorrectLabel.fadeIn(0.3)
                }
            }
            .store(in: &cancellables)

        viewStore.publisher.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                if $0 {
                    sendPhoneButton.fadeOut()
                    startLoading()
                    view.endEditing(true)
                } else {
                    stopLoading()
                    sendPhoneButton.fadeIn()
                }
            }
            .store(in: &cancellables)

        viewStore.publisher.popupMessage
            .compactMap { $0 }
            .sink {
                PopUp.display(.error(description: $0))
            }
            .store(in: &cancellables)
    }

    @objc private func textDidChange() {
        viewStore.send(.phoneChanged(phoneNumber.phone ?? ""))
    }
}
