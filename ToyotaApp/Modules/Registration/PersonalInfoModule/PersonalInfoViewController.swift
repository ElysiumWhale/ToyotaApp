import UIKit
import Combine
import ComposableArchitecture
import DesignKit

final class PersonalInfoView: BaseViewController,
                              Keyboardable,
                              Loadable {

    private let subtitleLabel = UILabel()
    private let firstNameTextField = InputTextField(.toyotaLeft)
    private let secondNameTextField = InputTextField(.toyotaLeft)
    private let lastNameTextField = InputTextField(.toyotaLeft)
    private let emailTextField = InputTextField(.toyotaLeft)
    private let birthTextField = InputTextField(.toyota(
        tintColor: .clear, alignment: .left
    ))
    private let containerView = UIView()
    private let fieldsStackView = UIStackView()
    private let actionButton = CustomizableButton(.toyotaAction())
    private let datePicker = UIDatePicker()

    private let viewStore: ViewStoreOf<PersonalInfoFeature>

    private var cancellables = Set<AnyCancellable>()

    private var fields: [InputTextField] {
        [
            firstNameTextField,
            lastNameTextField,
            secondNameTextField,
            emailTextField,
            birthTextField
        ]
    }

    let scrollView: UIScrollView! = UIScrollView()
    let loadingView = LoadingView()

    init(store: StoreOf<PersonalInfoFeature>) {
        self.viewStore = ViewStore(store)

        super.init()

        setupSubscriptions()
    }

    // MARK: - Initialazable
    override func addViews() {
        addSubviews(subtitleLabel, scrollView, actionButton)
        scrollView.addSubview(containerView)
        containerView.addSubview(fieldsStackView)
        fieldsStackView.addArrangedSubviews(
            firstNameTextField,
            lastNameTextField,
            secondNameTextField,
            emailTextField,
            birthTextField
        )
    }

    override func configureLayout() {
        view.hideKeyboard(when: .tapAndSwipe)

        subtitleLabel.edgesToSuperview(
            excluding: .bottom,
            insets: .horizontal(16),
            usingSafeArea: true
        )
        scrollView.edgesToSuperview(excluding: .top, insets: .horizontal(16))
        scrollView.topToBottom(of: subtitleLabel)

        containerView.edges(to: scrollView.contentLayoutGuide)
        containerView.width(to: scrollView.frameLayoutGuide)

        firstNameTextField.height(50)
        fieldsStackView.topToSuperview(offset: 16)
        fieldsStackView.horizontalToSuperview()
        fieldsStackView.bottomToSuperview(offset: -16, usingSafeArea: true)
        fieldsStackView.distribution = .fillEqually
        fieldsStackView.alignment = .fill
        fieldsStackView.spacing = 20
        fieldsStackView.axis = .vertical

        actionButton.centerXToSuperview()
        actionButton.size(.toyotaActionL)
        actionButton.bottomToSuperview(offset: -16, usingSafeArea: true)
    }

    override func configureAppearance() {
        navigationItem.largeTitleDisplayMode = .automatic
        subtitleLabel.font = .toyotaType(.semibold, of: 21)
        subtitleLabel.numberOfLines = 2
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        configureFields()

        view.backgroundColor = .systemBackground
        subtitleLabel.backgroundColor = view.backgroundColor
        containerView.backgroundColor = view.backgroundColor
    }

    override func localize() {
        navigationItem.title = .common(.data)
        subtitleLabel.text = .common(.fillPersonalInfo)
        firstNameTextField.placeholder = .common(.name)
        lastNameTextField.placeholder = .common(.lastName)
        secondNameTextField.placeholder = .common(.secondName)
        emailTextField.placeholder = .common(.email)
        birthTextField.placeholder = .common(.birthDate)
        actionButton.setTitle(.common(.next), for: .normal)
        configureTextIfNeeded()
    }

    override func configureActions() {
        datePicker.configure(
            .makeToolbar(#selector(dateDidSelect)),
            for: birthTextField
        )
        actionButton.addAction { [weak self] in
            self?.viewStore.send(.actionButtonDidPress)
        }
    }

    private func setupSubscriptions() {
        setupKeyboard(isSubscribing: true)

        viewStore.publisher.isLoading
            .sinkOnMain { [unowned self] in
                $0 ? startLoading() : stopLoading()
                loadingView.fade($0 ? .in() : .out())
            }
            .store(in: &cancellables)

        viewStore.publisher.popupMessage
            .compactMap { $0 }
            .sink { [unowned self] in
                PopUp.display(.error($0))
                viewStore.send(.popupDidShow)
            }
            .store(in: &cancellables)

        viewStore.publisher.needsValidation
            .filter { $0 }
            .sinkOnMain { [unowned self] _ in
                fields.forEach { $0.isValid(toggle: true) }
                viewStore.send(.fieldsDidValidate)
            }
            .store(in: &cancellables)
    }

    private func configureFields() {
        fields.forEach { field in
            field.leftPadding = 15
            field.maxSymbolCount = 30
            field.rule = .personalInfo
            field.delegate = self
            field.addTarget(
                self,
                action: #selector(textDidChange),
                for: .editingChanged
            )
        }
    }

    private func configureTextIfNeeded() {
        if let firstName = viewStore.personState[.firstName]?.value {
            firstNameTextField.setText(firstName)
        }
        if let secondName = viewStore.personState[.secondName]?.value {
            secondNameTextField.setText(secondName)
        }
        if let lastName = viewStore.personState[.lastName]?.value {
            lastNameTextField.setText(lastName)
        }
        if let email = viewStore.personState[.email]?.value {
            emailTextField.setText(email)
        }
        if let birth = viewStore.personState[.birth]?.value,
           let date = birth.asDate(with: .server) {
            datePicker.date = date
            birthTextField.setText(date.asString(.client))
        }
    }
}

// MARK: - Actions
private extension PersonalInfoView {
    @objc func dateDidSelect() {
        birthTextField.setText(datePicker.date.asString(.client))
        view.endEditing(true)
    }

    typealias FieldState = PersonalInfoFeature.FieldState
    typealias Field = PersonalInfoFeature.Fields

    @objc func textDidChange(_ sender: InputTextField) {
        let isValid = sender.isValid(toggle: false)
        switch sender {
        case firstNameTextField:
            sendFieldState(field: .firstName, sender.inputText, isValid)
        case secondNameTextField:
            sendFieldState(field: .secondName, sender.inputText, isValid)
        case lastNameTextField:
            sendFieldState(field: .lastName, sender.inputText, isValid)
        case emailTextField:
            sendFieldState(field: .email, sender.inputText, isValid)
        case birthTextField:
            sendFieldState(
                field: .birth,
                sender.inputText.toDateAsString(.client, .server) ?? .empty,
                isValid
            )
        default:
            return
        }
    }

    func sendFieldState(field: Fields, _ value: String, _ isValid: Bool) {
        viewStore.send(.personDidChange(field, FieldState(
            value: value,
            isValid: isValid
        )))
    }
}

// MARK: - UITextFieldDelegate
extension PersonalInfoView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            secondNameTextField.becomeFirstResponder()
        case secondNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            birthTextField.becomeFirstResponder()
        default:
            view.endEditing(false)
        }

        return false
    }
}
