import UIKit

final class PersonalInfoView: InitialazableViewController, Keyboardable, Loadable {
    private let subtitleLabel = UILabel()
    private let firstNameTextField = InputTextField()
    private let secondNameTextField = InputTextField()
    private let lastNameTextField = InputTextField()
    private let emailTextField = InputTextField()
    private let birthTextField = InputTextField()
    private let containerView = UIView()
    private let fieldsStackView = UIStackView()
    private let actionButton = CustomizableButton()
    private let datePicker = UIDatePicker()

    let scrollView: UIScrollView! = UIScrollView()
    let loadingView = LoadingView()

    let interactor: PersonalInfoControllerOutput

    var isLoading: Bool = false

    var fields: [InputTextField] {
        [
            firstNameTextField,
            lastNameTextField,
            secondNameTextField,
            emailTextField,
            birthTextField
        ]
    }

    init(interactor: PersonalInfoControllerOutput) {
        self.interactor = interactor

        super.init()
    }

    // MARK: - Initialazable
    override func addViews() {
        addSubviews(subtitleLabel, scrollView, actionButton)
        scrollView.addSubview(containerView)
        containerView.addSubview(fieldsStackView)
        fieldsStackView.addArrangedSubviews(firstNameTextField,
                                            lastNameTextField,
                                            secondNameTextField,
                                            emailTextField,
                                            birthTextField)
    }

    override func configureLayout() {
        hideKeyboardWhenTappedAround()

        subtitleLabel.edgesToSuperview(excluding: .bottom,
                                       insets: .horizontal(16),
                                       usingSafeArea: true)
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
        navigationController?.navigationBar.prefersLargeTitles = true
        subtitleLabel.font = .toyotaType(.semibold, of: 21)
        subtitleLabel.numberOfLines = 2
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        actionButton.rounded = true
        actionButton.titleLabel?.font = .toyotaType(.regular, of: 22)
        actionButton.normalColor = .appTint(.secondarySignatureRed)
        actionButton.highlightedColor = .appTint(.dimmedSignatureRed)
        configureFields()

        view.backgroundColor = .systemBackground
        containerView.backgroundColor = .systemBackground
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
    }

    override func configureActions() {
        datePicker.configure(with: #selector(dateDidSelect), for: birthTextField)
        actionButton.addTarget(self, action: #selector(actionButtonDidPress), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        setupKeyboard(isSubcribing: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        setupKeyboard(isSubcribing: false)
    }

    private func configureFields() {
        fields.forEach { field in
            field.backgroundColor = .appTint(.background)
            field.font = .toyotaType(.light, of: 23)
            field.cornerRadius = 10
            field.leftPadding = 15
            field.maxSymbolCount = 30
            field.rule = .personalInfo
            field.delegate = self
        }
    }
}

// MARK: - Actions
extension PersonalInfoView {
    @objc private func actionButtonDidPress() {
        guard fields.allSatisfy(\.isValid) else {
            PopUp.display(.error(description: .error(.checkInput)))
            return
        }

        actionButton.fadeOut()
        startLoading()
        interactor.setPerson(request: .init(firstName: firstNameTextField.inputText,
                                            secondName: secondNameTextField.inputText,
                                            lastName: lastNameTextField.inputText,
                                            email: emailTextField.inputText,
                                            date: datePicker.date.asString(.server)))
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
            case .success(let cities, let models, let colors):
                let cityPickerModule = CityPickerViewController()
                cityPickerModule.configure(with: cities, models: models, colors: colors)
                navigationController?.pushViewController(cityPickerModule, animated: true)
            case .failure(let errorMessage):
                PopUp.display(.error(description: errorMessage))
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
