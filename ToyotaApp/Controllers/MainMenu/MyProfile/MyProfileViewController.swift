import UIKit
import SwiftEntryKit

private enum EditingStates {
    case none
    case editing
    case loading
}

class MyProfileViewController: UIViewController {
    @IBOutlet private var firstNameTextField: UITextField!
    @IBOutlet private var secondNameTextField: UITextField!
    @IBOutlet private var lastNameTextField: UITextField!
    @IBOutlet private var birthTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var managerButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var saveButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var cancelButtonLeadingConstant: NSLayoutConstraint!

    private let datePicker: UIDatePicker = UIDatePicker()

    private let myCarsSegueCode = SegueIdentifiers.myProfileToCars
    private let settingsSegueCode = SegueIdentifiers.myProfileToSettings
    private let myManagersSegueCode = SegueIdentifiers.myManagersSegueCode

    // MARK: - Properties
    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }

    private var profile: Person { user.getPerson }

    private var state: EditingStates = .none {
        didSet { switchInterface(state) }
    }

    private var date: String = .empty {
        didSet { view.endEditing(true) }
    }

    private var textFieldsWithError: [UITextField: Bool] = [:]

    private var hasChanges: Bool {
        profile.firstName != firstNameTextField.text ||
        profile.secondName != secondNameTextField.text ||
        profile.lastName != lastNameTextField.text ||
        profile.email != emailTextField.text ||
        .formatDateForClient(from: profile.birthday) != birthTextField.text
    }

    private lazy var updateUserHandler: RequestHandler<Response> = {
        let handler = RequestHandler<Response>()

        handler.onSuccess = { [weak self] data in
            DispatchQueue.main.async {
                self?.handle(success: data)
            }
        }

        handler.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                PopUp.display(.error(description: error.message ?? .error(.savingError)))
                self?.state = .editing
            }
        }

        return handler
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.toyotaType(.regular, of: 17)
        ]
        hideKeyboardWhenTappedAround()
        configureDatePicker(datePicker, with: #selector(dateDidSelect), for: birthTextField)
        updateFields()

        let constraints = getConstraints(for: state)
        view.removeConstraint(saveButtonLeadingConstraint)
        view.addConstraint(constraints.save)
        saveButtonLeadingConstraint = constraints.save
        view.removeConstraint(cancelButtonLeadingConstant)
        view.addConstraint(constraints.cancel)
        cancelButtonLeadingConstant = constraints.cancel

        textFieldsWithError = [firstNameTextField: false, secondNameTextField: false,
                               lastNameTextField: false, emailTextField: false, birthTextField: false]
        for field in textFieldsWithError.keys {
            field.layer.cornerRadius = 5
            field.isEnabled = false
        }
    }

    @IBAction private func enterEditMode(sender: UIButton) {
        switch state {
            case .none: state = .editing
            case .loading: return
            case .editing: updateUserInfo()
        }
    }

    @IBAction private func cancelEdit(sender: UIButton) {
        if hasChanges {
            updateFields()
            for textField in textFieldsWithError.keys {
                textDidChange(sender: textField)
            }
        }
        state = .none
    }

    @objc private func dateDidSelect() {
        date = .formatDate(from: datePicker.date, withAssignTo: birthTextField)
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

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        state = .none
        switch segue.code {
            case myCarsSegueCode, settingsSegueCode:
                let navVC = segue.destination as? UINavigationController
                navVC?.navigationBar.tintColor = UIColor.appTint(.secondarySignatureRed)
                let destinationVC = navVC?.topViewController as? WithUserInfo
                destinationVC?.setUser(info: user)
            case myManagersSegueCode:
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

// MARK: - UI
extension MyProfileViewController {
    private func getConstraints(for state: EditingStates) -> (save: NSLayoutConstraint, cancel: NSLayoutConstraint) {
        let isEditing = state == .editing
        let constant: CGFloat = isEditing ? 20 : view.bounds.width/2 - saveButton.bounds.width/2
        let saveConstraint = NSLayoutConstraint(item: saveButton as Any,
                                                attribute: .leading, relatedBy: .equal,
                                                toItem: view, attribute: .leading,
                                                multiplier: 1.0, constant: constant)
        let cancelConstraint = NSLayoutConstraint(item: cancelButton as Any,
                                                  attribute: .leading, relatedBy: .equal,
                                                  toItem: view, attribute: .leading,
                                                  multiplier: 1.0,
                                                  constant: isEditing ? view.bounds.width - 20 - cancelButton.bounds.width : constant)
        return (saveConstraint, cancelConstraint)
    }

    private func switchInterface(_ state: EditingStates) {
        let isEditing = state == .editing
        for field in textFieldsWithError.keys {
            field.isEnabled = isEditing ? true : false
        }

        let constraints = getConstraints(for: state)

        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: { [self] in
            cancelButton.isEnabled = isEditing
            view.removeConstraint(saveButtonLeadingConstraint)
            view.addConstraint(constraints.save)
            view.removeConstraint(cancelButtonLeadingConstant)
            view.addConstraint(constraints.cancel)
            view.layoutIfNeeded()

            if state != .loading {
                saveButton.setTitle(isEditing ? .common(.save) : .common(.edit), for: .normal)
            }

            saveButtonLeadingConstraint = constraints.save
            cancelButtonLeadingConstant = constraints.cancel
        })

        if state != .loading {
            date = .empty
        }
    }

    private func updateFields() {
        firstNameTextField.text = profile.firstName
        secondNameTextField.text = profile.secondName
        lastNameTextField.text = profile.lastName
        emailTextField.text = profile.email
        birthTextField.text = .formatDateForClient(from: profile.birthday)
        datePicker.date = .dateFromServer(date: profile.birthday)
        date = .empty
        managerButton.isHidden = user.getCars.array.count < 1
    }

    @IBAction private func textDidChange(sender: UITextField) {
        let isValid = sender.text != nil && !sender.text!.isEmpty && sender.text!.count < 25

        sender.toggle(state: isValid ? .normal : .error)
        textFieldsWithError[sender] = !isValid
    }
}

// MARK: - Update user information logic
extension MyProfileViewController {
    private func updateUserInfo() {
        guard hasChanges else {
            state = .none
            return
        }

        guard textFieldsWithError.allSatisfy({ !$0.value }) else {
            PopUp.display(.error(description: .error(.checkInput)))
            return
        }

        state = .loading
        NetworkService.makeRequest(page: .profile(.editProfile),
                                   params: requestParams,
                                   handler: updateUserHandler)
    }

    private var requestParams: RequestItems {
        [(.auth(.userId), user.getId),
         (.personalInfo(.firstName), firstNameTextField.text),
         (.personalInfo(.secondName), secondNameTextField.text),
         (.personalInfo(.lastName), lastNameTextField.text),
         (.personalInfo(.email), emailTextField.text),
         (.personalInfo(.birthday), date)]
    }

    private func handle(success response: Response) {
        user.updatePerson(from: Person(firstName: firstNameTextField.text!,
                                       lastName: lastNameTextField.text!,
                                       secondName: secondNameTextField.text!,
                                       email: emailTextField.text!,
                                       birthday: date))
        PopUp.display(.success(description: .common(.personalDataSaved)))
        state = .none
    }
}

// MARK: - WithUserInfo
extension MyProfileViewController: WithUserInfo {
    func subscribe(on proxy: UserProxy) {
        proxy.getNotificator.add(observer: self)
    }

    func unsubscribe(from proxy: UserProxy) {
        proxy.getNotificator.remove(obsever: self)
    }

    func userDidUpdate() {
        DispatchQueue.main.async { [self] in
            view.setNeedsLayout()
            updateFields()
        }
    }

    func setUser(info: UserProxy) {
        user = info
    }
}
