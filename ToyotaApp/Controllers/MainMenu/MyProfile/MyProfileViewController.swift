import UIKit

private enum EditingStates {
    case none
    case editing
    case loading
}

class MyProfileViewController: UIViewController {
    // MARK: - UI properties
    @IBOutlet private var firstNameTextField: InputTextField!
    @IBOutlet private var secondNameTextField: InputTextField!
    @IBOutlet private var lastNameTextField: InputTextField!
    @IBOutlet private var birthTextField: NoPasteTextField!
    @IBOutlet private var emailTextField: InputTextField!
    @IBOutlet private var managerButton: CustomizableButton!
    @IBOutlet private var cancelButton: CustomizableButton!
    @IBOutlet private var saveButton: CustomizableButton!
    @IBOutlet private var saveLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var cancelLeadingConstraint: NSLayoutConstraint!

    private let datePicker: UIDatePicker = UIDatePicker()

    private lazy var fields = [firstNameTextField,
                               secondNameTextField,
                               lastNameTextField,
                               emailTextField].compactMap { $0 }

    // MARK: - Properties
    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }

    private var profile: Person { user.person }

    private var state: EditingStates = .none {
        didSet { switchInterface(state) }
    }

    private var date: String = .empty {
        didSet { view.endEditing(true) }
    }

    private lazy var updateUserHandler: RequestHandler<SimpleResponse> = {
        RequestHandler<SimpleResponse>()
            .observe(on: .main)
            .bind { [weak self] response in
                self?.handle(success: response)
            } onFailure: { [weak self] error in
                PopUp.display(.error(description: error.message ?? .error(.savingError)))
                self?.state = .editing
            }
    }()

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.toyotaType(.regular, of: 17)
        ]
        hideKeyboardWhenTappedAround()
        view.hideKeyboardWhenSwipedDown()
        configureDatePicker(datePicker, with: #selector(dateDidSelect), for: birthTextField)
        refreshFields()

        let constraints = getConstraints(for: state)
        saveLeadingConstraint = view.swapConstraints(from: saveLeadingConstraint, to: constraints.save)
        cancelLeadingConstraint = view.swapConstraints(from: cancelLeadingConstraint, to: constraints.cancel)

        for field in fields {
            field.rule = .personalInfo
        }
        fields.append(birthTextField)
    }

    @IBAction private func enterEditMode(sender: UIButton) {
        switch state {
            case .none: state = .editing
            case .loading: return
            case .editing: updateUserInfo()
        }
    }

    @IBAction private func cancelEdit(sender: UIButton) {
        refreshFields()
        state = .none
    }

    @IBAction private func logout(sender: Any?) {
        PopUp.displayChoice(with: .common(.actionConfirmation),
                            description: .question(.quit),
                            confirmText: .common(.yes), declineText: .common(.no)) {
            KeychainManager.clearAll()
            DefaultsManager.clearAll()
            NavigationService.loadAuth()
        }
    }

    @IBAction private func showSettings(sender: Any?) {
        let root = SettingsViewController(user: user)
        let navigation = UINavigationController(rootViewController: root)
        present(navigation, animated: true)
    }

    @objc private func dateDidSelect() {
        date = datePicker.date.asString(.server)
        birthTextField.text = datePicker.date.asString(.client)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        state = .none
        switch segue.code {
            case .myProfileToCars, .myProfileToSettings:
                let navVC = segue.destination as? UINavigationController
                navVC?.navigationBar.tintColor = UIColor.appTint(.secondarySignatureRed)
                navVC?.setUserForChildren(user)
            case .myManagersSegueCode:
                let destinationVC = segue.destination as? WithUserInfo
                destinationVC?.setUser(info: user)
            default: return
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        state = .none
    }
}

// MARK: - Layout
extension MyProfileViewController {
    private func getConstraints(for state: EditingStates) -> (save: NSLayoutConstraint, cancel: NSLayoutConstraint) {
        let isEditing = state == .editing
        let constant: CGFloat = isEditing ? 20 : view.bounds.width/2 - saveButton.bounds.width/2
        let saveConstraint = NSLayoutConstraint(item: saveButton as Any,
                                                attribute: .leading, relatedBy: .equal,
                                                toItem: view, attribute: .leading,
                                                multiplier: 1.0, constant: constant)
        let cancelConstant = isEditing ? view.bounds.width - 20 - cancelButton.bounds.width : constant
        let cancelConstraint = NSLayoutConstraint(item: cancelButton as Any,
                                                  attribute: .leading, relatedBy: .equal,
                                                  toItem: view, attribute: .leading,
                                                  multiplier: 1.0,
                                                  constant: cancelConstant)
        return (saveConstraint, cancelConstraint)
    }

    private func switchInterface(_ state: EditingStates) {
        let isEditing = state == .editing
        cancelButton.isEnabled = isEditing
        let constraints = getConstraints(for: state)

        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: { [self] in
            for field in fields {
                field.isEnabled = isEditing
                field.backgroundColor = isEditing ? .appTint(.secondaryGray) : .appTint(.background)
            }
            saveLeadingConstraint = view.swapConstraints(from: saveLeadingConstraint, to: constraints.save)
            cancelLeadingConstraint = view.swapConstraints(from: cancelLeadingConstraint, to: constraints.cancel)
            view.layoutIfNeeded()

            if state != .loading {
                saveButton.setTitle(isEditing ? .common(.save) : .common(.edit), for: .normal)
            }
        })

        if state != .loading {
            date = .empty
        }
    }

    private func refreshFields() {
        firstNameTextField.text = profile.firstName
        secondNameTextField.text = profile.secondName
        lastNameTextField.text = profile.lastName
        emailTextField.text = profile.email
        datePicker.date = profile.birthday.asDate(with: .server) ?? Date()
        dateDidSelect()
        managerButton.isHidden = user.cars.value.count < 1
    }
}

// MARK: - Update user
extension MyProfileViewController {
    private var hasChanges: Bool {
        profile.firstName != firstNameTextField.inputText ||
        profile.secondName != secondNameTextField.inputText ||
        profile.lastName != lastNameTextField.inputText ||
        profile.email != emailTextField.inputText ||
        profile.birthday.asDate(with: .server)?.asString(.client) != birthTextField.inputText
    }

    private func updateUserInfo() {
        guard hasChanges else {
            state = .none
            return
        }

        guard !fields.any({ !$0.isValid }) else {
            PopUp.display(.error(description: .error(.checkInput)))
            return
        }

        state = .loading
        let body = SetProfileBody(brandId: firstNameTextField.inputText,
                                  userId: KeychainManager<UserId>.get()!.value,
                                  firstName: firstNameTextField.inputText,
                                  secondName: secondNameTextField.inputText,
                                  lastName: lastNameTextField.inputText,
                                  email: emailTextField.inputText,
                                  birthday: date)
        InfoService().updateProfile(with: body, handler: updateUserHandler)
    }

    private func handle(success response: SimpleResponse) {
        user.updatePerson(from: Person(firstName: firstNameTextField.inputText,
                                       lastName: lastNameTextField.inputText,
                                       secondName: secondNameTextField.inputText,
                                       email: emailTextField.inputText,
                                       birthday: date))
        PopUp.display(.success(description: .common(.personalDataSaved)))
        state = .none
    }
}

// MARK: - WithUserInfo
extension MyProfileViewController: WithUserInfo {
    func subscribe(on proxy: UserProxy) {
        proxy.notificator.add(observer: self)
    }

    func unsubscribe(from proxy: UserProxy) {
        proxy.notificator.remove(obsever: self)
    }

    func userDidUpdate() {
        DispatchQueue.main.async { [self] in
            view.setNeedsLayout()
            refreshFields()
        }
    }

    func setUser(info: UserProxy) {
        user = info
    }
}
