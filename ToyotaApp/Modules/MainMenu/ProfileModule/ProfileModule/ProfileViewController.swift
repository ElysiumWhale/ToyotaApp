import UIKit
import DesignKit

enum ProfileOutput: Hashable {
    case showBookings
    case showSettings
    case showCars
    case showManagers
    case logout
}

protocol ProfileModule: UIViewController, Outputable<ProfileOutput> { }

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
    private let firstNameTextField = InputTextField(.toyota)
    private let secondNameTextField = InputTextField(.toyota)
    private let lastNameTextField = InputTextField(.toyota)
    private let emailTextField = InputTextField(.toyota)
    private let birthTextField = NoPasteTextField(.toyota)
    private let managerButton = CustomizableButton(.toyotaAction(18))
    private let cancelButton = CustomizableButton(.toyotaAction(18))
    private let saveButton = CustomizableButton(.toyotaAction(18))
    private let bookingsButton = CustomizableButton(.toyotaSecondary)
    private let carsButton = CustomizableButton(.toyotaSecondary)
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

    var output: ParameterClosure<ProfileOutput>?

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
        fieldsStack.horizontalToSuperview(insets: .horizontal(16))
        fieldsStack.topToSuperview(offset: 8, usingSafeArea: true)
        firstNameTextField.height(45)

        for button in [saveButton, cancelButton] {
            button.topToBottom(of: fieldsStack, offset: 16)
            button.size(.toyotaActionS)
        }

        saveLeadingConstraint = saveButton.centerXToSuperview()
        cancelLeadingConstraint = cancelButton.centerXToSuperview()

        managerButton.size(.toyotaActionS)
        managerButton.topToBottom(of: saveButton, offset: 16)
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

        fields.forEach {
            $0.rule = .personalInfo
            $0.isEnabled = false
        }

        birthTextField.rule = .notEmpty
        birthTextField.tintColor = .clear

        bookingsButton.setImage(.bookings, for: .normal)
        carsButton.setImage(.car, for: .normal)

        bottomButtonsStack.cornerRadius = 8
        bottomButtonsStack.clipsToBounds = true
    }

    override func configureActions() {
        view.hideKeyboard(when: .tapAndSwipe)

        datePicker.configure(
            .makeToolbar(#selector(dateDidSelect)),
            for: birthTextField
        )

        managerButton.addAction { [weak self] in
            self?.output?(.showManagers)
        }
        bookingsButton.addAction { [weak self] in
            self?.output?(.showBookings)
        }
        carsButton.addAction { [weak self] in
            self?.output?(.showCars)
        }

        saveButton.addTarget(
            self, action: #selector(enterEditMode), for: .touchUpInside
        )
        cancelButton.addTarget(
            self, action: #selector(cancelEdit), for: .touchUpInside
        )

        interactor.onUserUpdateFailure = { [weak self] errorMessage in
            PopUp.display(.error(errorMessage))
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
            PopUp.display(.error(.error(.checkInput)))
            return
        }

        state = .loading
        interactor.updateProfile(Person(
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

        UIView.animate(
            withDuration: 0.5,
            delay: .zero,
            options: .curveEaseInOut
        ) { [unowned self] in
            for field in fields {
                field.isEnabled = isEditing
                field.backgroundColor = isEditing
                    ? .appTint(.secondaryGray)
                    : .appTint(.background)
            }

            view.layoutIfNeeded()
        }

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
        output?(.showSettings)
    }

    @objc func logout() {
        PopUp.displayChoice(
            with: .common(.actionConfirmation),
            description: .question(.quit),
            confirmText: .common(.yes),
            declineText: .common(.no)
        ) { [weak self] in
            self?.output?(.logout)
        }
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
            DispatchQueue.main.async { [self] in
                view.setNeedsLayout()
                refreshFields()
                state = .none
            }
        default:
            return
        }
    }
}
