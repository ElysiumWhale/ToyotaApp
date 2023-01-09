import UIKit
import DesignKit

final class PersonalInfoView: BaseViewController,
                              Keyboardable,
                              Loadable {

    private let subtitleLabel = UILabel()
    private let firstNameTextField = InputTextField()
    private let secondNameTextField = InputTextField()
    private let lastNameTextField = InputTextField()
    private let emailTextField = InputTextField()
    private let birthTextField = InputTextField()
    private let containerView = UIView()
    private let fieldsStackView = UIStackView()
    private let actionButton = CustomizableButton(configuration: .toyotaAction())
    private let datePicker = UIDatePicker()

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
    let interactor: PersonalInfoViewOutput

    init(interactor: PersonalInfoViewOutput) {
        self.interactor = interactor

        super.init()

        navigationItem.title = .common(.data)
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
        actionButton.size(.init(width: 245, height: 43))
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
        subtitleLabel.text = .common(.fillPersonalInfo)
        firstNameTextField.placeholder = .common(.name)
        lastNameTextField.placeholder = .common(.lastName)
        secondNameTextField.placeholder = .common(.secondName)
        emailTextField.placeholder = .common(.email)
        birthTextField.placeholder = .common(.birthDate)
        actionButton.setTitle(.common(.next), for: .normal)

        configureTextIfNeeded(for: interactor.state)
    }

    override func configureActions() {
        datePicker.configure(
            .buildToolbar(with: #selector(dateDidSelect)),
            for: birthTextField
        )
        actionButton.addTarget(
            self, action: #selector(actionButtonDidPress), for: .touchUpInside
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        setupKeyboard(isSubscribing: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        setupKeyboard(isSubscribing: false)
    }

    override func viewDidLayoutSubviews() {
        fields.forEach { $0.applyCornerMask(radius: 10) }
    }

    private func configureFields() {
        fields.forEach { field in
            field.backgroundColor = .appTint(.background)
            field.tintColor = .appTint(.secondarySignatureRed)
            field.font = .toyotaType(.light, of: 23)
            field.leftPadding = 15
            field.maxSymbolCount = 30
            field.rule = .personalInfo
            field.delegate = self
        }

        birthTextField.tintColor = .clear
    }

    private func configureTextIfNeeded(for state: PersonalDataStoreState) {
        switch state {
        case .empty:
            return
        case .configured(let profile):
            firstNameTextField.text = profile.firstName
            secondNameTextField.text = profile.secondName
            lastNameTextField.text = profile.lastName
            emailTextField.text = profile.email
            birthTextField.text = profile.birthdayDate?.asString(.client)
        }
    }
}

// MARK: - Actions
extension PersonalInfoView {
    @objc private func actionButtonDidPress() {
        guard fields.areValid else {
            PopUp.display(.error(description: .error(.checkInput)))
            return
        }

        actionButton.fadeOut()
        startLoading()
        interactor.setPerson(request: .init(
            firstName: firstNameTextField.inputText,
            secondName: secondNameTextField.inputText,
            lastName: lastNameTextField.inputText,
            email: emailTextField.inputText,
            date: datePicker.date.asString(.server)
        ))
    }

    @objc private func dateDidSelect() {
        birthTextField.text = datePicker.date.asString(.client)
        view.endEditing(true)
    }
}

// MARK: - PersonalInfoPresenterOutput
extension PersonalInfoView: PersonalInfoPresenterOutput {
    func handle(state viewModel: PersonalInfoModels.SetPersonViewModel) {
        stopLoading()
        actionButton.fadeIn()

        switch viewModel {
        case let .success(cities, models, colors):
            let cityPickerModule = RegisterFlow.cityModule(cities)

            cityPickerModule.onCityPick = { [weak self] _ in
                let addCar = RegisterFlow.addCarModule(
                    scenario: .register,
                    models: models,
                    colors: colors
                )
                self?.navigationController?.pushViewController(
                    addCar, animated: true
                )
            }

            navigationController?.pushViewController(
                cityPickerModule, animated: true
            )
        case let .failure(message):
            PopUp.display(.error(description: message))
        }
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
