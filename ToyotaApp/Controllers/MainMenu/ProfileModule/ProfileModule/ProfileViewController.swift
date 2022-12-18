import UIKit
import DesignKit

protocol ProfileModule: UIViewController {
    var onShowBookings: Closure? { get set }
    var onShowSettings: Closure? { get set }
    var onShowCars: Closure? { get set }
    var onShowManagers: Closure? { get set }
    var onLogout: Closure? { get set }
}

final class ProfileViewController: BaseViewController,
                                   Loadable,
                                   ProfileModule {

    enum EditingStates {
        case none
        case editing
        case loading
    }

    private let interactor: ProfileInteractor

    // MARK: - UI
    private let firstNameTextField = InputTextField()
    private let secondNameTextField = InputTextField()
    private let lastNameTextField = InputTextField()
    private let emailTextField = InputTextField()
    private let birthTextField = NoPasteTextField()
    private let managerButton = CustomizableButton()
    private let cancelButton = CustomizableButton()
    private let saveButton = CustomizableButton()
    private let bookingsButton = CustomizableButton()
    private let carsButton = CustomizableButton()
    private let fieldsStack = UIStackView()
    private let bottomButtonsStack = UIStackView()
    private let datePicker = UIDatePicker()

    private var saveLeadingConstraint: NSLayoutConstraint!
    private var cancelLeadingConstraint: NSLayoutConstraint!

    private var state: EditingStates = .none {
        didSet {
            animateButtonsAndFields(for: state)
        }
    }

    private var date: String = .empty {
        didSet {
            view.endEditing(true)
        }
    }

    private var hasChanges: Bool {
        interactor.profile.firstName != firstNameTextField.inputText ||
        interactor.profile.secondName != secondNameTextField.inputText ||
        interactor.profile.lastName != lastNameTextField.inputText ||
        interactor.profile.email != emailTextField.inputText ||
        interactor.profile.birthday.asDate(with: .server)?.asString(.client) != birthTextField.inputText
    }

    let loadingView = LoadingView()

    var isLoading: Bool = false

    var onShowBookings: Closure?
    var onShowSettings: Closure?
    var onShowCars: Closure?
    var onShowManagers: Closure?
    var onLogout: Closure?

    init(interactor: ProfileInteractor, notificator: EventNotificator = .shared) {
        self.interactor = interactor

        super.init()

        notificator.add(self, for: .userUpdate)
    }

    // MARK: - InitialazableView
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshFields()
    }

    override func addViews() {
        fieldsStack.addArrangedSubviews(
            firstNameTextField,
            secondNameTextField,
            lastNameTextField,
            emailTextField,
            birthTextField
        )
        bottomButtonsStack.addArrangedSubviews(bookingsButton, carsButton)
        addSubviews(
            fieldsStack,
            managerButton,
            cancelButton,
            saveButton,
            bottomButtonsStack
        )

        let leftItem = UIBarButtonItem(
            image: .settings,
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )
        leftItem.tintColor = .appTint(.signatureGray)
        let rightItem = UIBarButtonItem(
            image: .logout,
            style: .plain,
            target: self,
            action: #selector(logout)
        )
        rightItem.tintColor = .appTint(.signatureGray)

        navigationItem.leftBarButtonItem = leftItem
        navigationItem.rightBarButtonItem = rightItem
    }

    override func configureLayout() {
        fieldsStack.axis = .vertical
        fieldsStack.distribution = .fillEqually
        fieldsStack.spacing = 15
        fieldsStack.edgesToSuperview(
            excluding: .bottom,
            insets: .uniform(16),
            usingSafeArea: true
        )
        firstNameTextField.height(45)

        for button in [saveButton, cancelButton] {
            button.topToBottom(of: fieldsStack, offset: 18)
            button.size(.init(width: 160, height: 43))
        }

        saveLeadingConstraint = saveButton.centerXToSuperview()
        cancelLeadingConstraint = cancelButton.centerXToSuperview()

        managerButton.size(.init(width: 160, height: 43))
        managerButton.topToBottom(of: saveButton, offset: 18)
        managerButton.centerXToSuperview()

        bottomButtonsStack.distribution = .fillEqually
        bottomButtonsStack.spacing = 3
        bottomButtonsStack.cornerRadius = 8
        bottomButtonsStack.edgesToSuperview(
            excluding: .top,
            insets: .uniform(16),
            usingSafeArea: true
        )
        bookingsButton.height(60)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.toyotaType(.regular, of: 17)
        ]

        for field in fields {
            field.rule = .personalInfo
            field.cornerRadius = 10
            field.backgroundColor = .appTint(.background)
            field.tintColor = .appTint(.secondarySignatureRed)
            field.font = .toyotaType(.light, of: 22)
            field.textAlignment = .center
            field.tintColor = .appTint(.secondarySignatureRed)
            field.isEnabled = false
        }

        birthTextField.rule = .notEmpty
        birthTextField.tintColor = .clear

        for button in buttons {
            button.rounded = true
            button.titleLabel?.font = .toyotaType(.regular, of: 18)
            button.normalColor = .appTint(.secondarySignatureRed)
            button.highlightedColor = .appTint(.dimmedSignatureRed)
        }

        for bottomButton in [bookingsButton, carsButton] {
            bottomButton.normalColor = .appTint(.background)
            bottomButton.highlightedColor = .appTint(.secondarySignatureRed)
            bottomButton.setTitleColor(.appTint(.signatureGray), for: .normal)
            bottomButton.tintColor = .appTint(.signatureGray)
            bottomButton.titleLabel?.font = .toyotaType(.semibold, of: 18)
        }

        bookingsButton.setImage(.bookings, for: .normal)
        carsButton.setImage(.car, for: .normal)

        bottomButtonsStack.cornerRadius = 8
        bottomButtonsStack.clipsToBounds = true
    }

    override func configureActions() {
        view.hideKeyboard(when: .tapAndSwipe)

        datePicker.configure(
            .buildToolbar(with: #selector(dateDidSelect)),
            for: birthTextField
        )

        managerButton.addAction { [weak self] in
            self?.onShowManagers?()
        }

        bookingsButton.addAction { [weak self] in
            self?.onShowBookings?()
        }

        carsButton.addAction { [weak self] in
            self?.onShowCars?()
        }

        saveButton.addTarget(
            self, action: #selector(enterEditMode), for: .touchUpInside
        )
        cancelButton.addTarget(
            self, action: #selector(cancelEdit), for: .touchUpInside
        )

        interactor.onUserUpdateFailure = { [weak self] errorMessage in
            PopUp.display(.error(description: errorMessage))
            self?.state = .editing
        }
    }

    override func localize() {
        saveButton.setTitle(.common(.edit), for: .normal)
        cancelButton.setTitle(.common(.cancel), for: .normal)
        managerButton.setTitle(.common(.myManager), for: .normal)
        firstNameTextField.placeholder = .common(.name)
        lastNameTextField.placeholder = .common(.lastName)
        secondNameTextField.placeholder = .common(.secondName)
        emailTextField.placeholder = .common(.email)
        birthTextField.placeholder = .common(.birthDate)
        bookingsButton.setTitle("  " + .common(.bookings), for: .normal)
        carsButton.setTitle("  " + .common(.myAuto), for: .normal)
        navigationItem.title = .common(.profile)
    }

    // MARK: - Actions
    @objc private func enterEditMode() {
        switch state {
        case .none:
            state = .editing
        case .loading:
            return
        case .editing:
            updateUserInfo()
        }
    }

    @objc private func cancelEdit() {
        refreshFields()
        state = .none
    }

    @objc private func dateDidSelect() {
        date = datePicker.date.asString(.server)
        birthTextField.text = datePicker.date.asString(.client)
    }

    private func refreshFields() {
        firstNameTextField.text = interactor.profile.firstName
        secondNameTextField.text = interactor.profile.secondName
        lastNameTextField.text = interactor.profile.lastName
        emailTextField.text = interactor.profile.email
        datePicker.date = interactor.profile.birthday.asDate(with: .server) ?? Date()
        dateDidSelect()
        managerButton.isHidden = interactor.user.cars.value.count < 1
    }

    private func updateUserInfo() {
        guard hasChanges else {
            state = .none
            return
        }

        guard fields.areValid else {
            PopUp.display(.error(description: .error(.checkInput)))
            return
        }

        state = .loading
        interactor.updateProfile(.init(
            firstName: firstNameTextField.inputText,
            lastName: lastNameTextField.inputText,
            secondName: secondNameTextField.inputText,
            email: emailTextField.inputText,
            birthday: date
        ))
    }
}

// MARK: - UI helpers
private extension ProfileViewController {
    var buttons: [CustomizableButton] {
        [
            managerButton,
            cancelButton,
            saveButton
        ]
    }

    var fields: [InputTextField] {
        [
            firstNameTextField,
            secondNameTextField,
            lastNameTextField,
            emailTextField,
            birthTextField
        ]
    }

    func animateButtonsAndFields(for state: EditingStates) {
        let isEditing = state == .editing
        cancelButton.isEnabled = isEditing

        [cancelLeadingConstraint, saveLeadingConstraint].deActivate()
        saveLeadingConstraint = isEditing
            ? saveButton.leadingToSuperview(offset: 16)
            : saveButton.centerXToSuperview()
        cancelLeadingConstraint = isEditing
            ? cancelButton.trailingToSuperview(offset: 16)
            : cancelButton.centerXToSuperview()

        UIView.animate(withDuration: 0.4,
                       delay: .zero,
                       options: .curveEaseInOut,
                       animations: { [self] in
            for field in fields {
                field.isEnabled = isEditing
                field.backgroundColor = isEditing
                    ? .appTint(.secondaryGray)
                    : .appTint(.background)
            }

            view.layoutIfNeeded()
        })

        if state != .loading {
            stopLoading()
            let title: String = isEditing ? .common(.save) : .common(.edit)
            saveButton.setTitle(title, for: .normal)
            date = .empty
        } else {
            startLoading()
        }
    }
}

// MARK: - Navigation
private extension ProfileViewController {
    @objc func showSettings() {
        onShowSettings?()
    }

    @objc func logout() {
        onLogout?()
    }
}

// MARK: - ObservesEvents
extension ProfileViewController: ObservesEvents {
    func handle(
        event: EventNotificator.AppEvents,
        notificator: EventNotificator
    ) {
        switch event {
        case .userUpdate:
            dispatch { [self] in
                view.setNeedsLayout()
                refreshFields()
                state = .none
            }
        default:
            return
        }
    }
}
