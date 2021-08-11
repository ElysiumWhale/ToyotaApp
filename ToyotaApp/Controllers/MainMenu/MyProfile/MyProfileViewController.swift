import UIKit
import SwiftEntryKit

private enum EditingStates {
    case none
    case isEditing
    case isLoading
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

    private let myCarsSegueCode = SegueIdentifiers.MyProfileToCars
    private let settingsSegueCode = SegueIdentifiers.MyProfileToSettings
    private let myManagersSegueCode = SegueIdentifiers.MyManagersSegueCode

    // MARK: - Properties
    #warning("todo: make optional")
    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }

    private var profile: Person { user.getPerson }

    private var state: EditingStates = .none {
        didSet { switchInterface(state) }
    }

    private var date: String = "" {
        didSet { view.endEditing(true) }
    }

    private var textFieldsWithError: [UITextField: Bool] = [:]

    private var hasChanges: Bool {
        profile.firstName != firstNameTextField.text ||
        profile.secondName != secondNameTextField.text ||
        profile.lastName != lastNameTextField.text ||
        profile.email != emailTextField.text ||
        formatDateForClient(from: profile.birthday) != birthTextField.text
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        }
    }

    @IBAction private func enterEditMode(sender: UIButton) {
        switch state {
            case .none: state = .isEditing
            case .isLoading: return
            case .isEditing: updateUserInfo()
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

    @IBAction private func dateDidSelect(sender: Any?) {
        date = formatDate(from: datePicker.date, withAssignTo: birthTextField)
    }

    @IBAction private func logout(sender: Any?) {
        PopUp.displayChoice(with: "Подтверждние действия",
                            description: "Вы действительно хотите выйти?",
                            confirmText: CommonText.yes, declineText: CommonText.no) {
            KeychainManager.clearAll()
            SwiftEntryKit.dismiss()
            NavigationService.loadAuth()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case myCarsSegueCode, settingsSegueCode:
                let navVC = segue.destination as? UINavigationController
                navVC?.navigationBar.tintColor = UIColor.mainAppTint
                let destinationVC = navVC?.topViewController as? WithUserInfo
                destinationVC?.setUser(info: user)
            case myManagersSegueCode:
                let destinationVC = segue.destination as? WithUserInfo
                destinationVC?.setUser(info: user)
            default: return
        }
    }
}

// MARK: - UI
extension MyProfileViewController {
    private func getConstraints(for state: EditingStates) -> (save: NSLayoutConstraint, cancel: NSLayoutConstraint) {
        let isEditing = state == .isEditing
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
        let isEditing = state == .isEditing
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
            
            if state != .isLoading {
                saveButton.setTitle(isEditing ? CommonText.save : CommonText.edit, for: .normal)
            }
            
            saveButtonLeadingConstraint = constraints.save
            cancelButtonLeadingConstant = constraints.cancel
        })
        
        if state != .isLoading {
            date = ""
        }
    }

    private func updateFields() {
        firstNameTextField.text = profile.firstName
        secondNameTextField.text = profile.secondName
        lastNameTextField.text = profile.lastName
        birthTextField.text = formatDateForClient(from: profile.birthday)
        datePicker.date = dateFromServer(date: profile.birthday)
        date = ""
        emailTextField.text = profile.email
        managerButton.isHidden = user.getCars.array.count < 1
    }

    @IBAction private func textDidChange(sender: UITextField) {
        if let text = sender.text, !text.isEmpty, text.count < 25 {
            sender.toggleErrorState(hasError: false)
            textFieldsWithError[sender] = false
        } else {
            sender.toggleErrorState(hasError: true)
            textFieldsWithError[sender] = true
        }
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
            PopUp.display(.error(description: "Неккоректные данные. Проверьте введенную информацию!"))
            return
        }
        
        state = .isLoading
        NetworkService.shared.makePostRequest(page: RequestPath.Profile.editProfile,
                                              params: buildRequestParams(),
                                              completion: userDidUpdateCompletion)
    }

    private func buildRequestParams() -> [URLQueryItem] {
        var params: [URLQueryItem] = [URLQueryItem(name: RequestKeys.Auth.userId, value: user.getId)]
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.firstName, value: firstNameTextField.text))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.secondName, value: secondNameTextField.text))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.lastName, value: lastNameTextField.text))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.email, value: emailTextField.text))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.birthday, value: date))
        return params
    }

    private func userDidUpdateCompletion(for response: Result<Response, ErrorResponse>) {
        switch response {
            case .success:
                DispatchQueue.main.async { [self] in
                    user.update(Person(firstName: firstNameTextField.text!,
                                       lastName: lastNameTextField.text!,
                                       secondName: secondNameTextField.text!,
                                       email: emailTextField.text!,
                                       birthday: date))
                    PopUp.display(.success(description: "Личная информация успешно обновлена"))
                    state = .none
                }
            case .failure:
                DispatchQueue.main.async { [weak self] in
                    PopUp.display(.error(description: "Произошла ошибка при сохранении данных, повторите попытку позже"))
                    self?.state = .isEditing
                }
        }
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
            view.layoutIfNeeded()
            updateFields()
        }
    }

    func setUser(info: UserProxy) {
        user = info
    }
}
