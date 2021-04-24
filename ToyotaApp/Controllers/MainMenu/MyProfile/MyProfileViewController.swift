import UIKit
import SwiftEntryKit

fileprivate enum EditingStates {
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
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var saveButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var cancelButtonLeadingConstant: NSLayoutConstraint!
    
    private let datePicker: UIDatePicker = UIDatePicker()
    
    private let myCarsSegueCode = SegueIdentifiers.MyProfileToCars
    private let settingsSegueCode = SegueIdentifiers.MyProfileToSettings
    
    //MARK: - Properties
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
    
    private var textFieldsWithError: [UITextField : Bool] = [:]
    
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
        
        let saveConstraint = NSLayoutConstraint(item: saveButton as Any, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: view.bounds.width/2 - saveButton.bounds.width/2)
        view.removeConstraint(saveButtonLeadingConstraint)
        view.addConstraint(saveConstraint)
        saveButtonLeadingConstraint = saveConstraint
        
        textFieldsWithError = [firstNameTextField : false, secondNameTextField : false,
                               lastNameTextField : false, emailTextField : false, birthTextField : false]
    }
    
    private func switchInterface(_ state: EditingStates) {
        let isEditing = state == .isEditing
        for field in textFieldsWithError.keys {
            field.isEnabled = isEditing ? true : false
        }
        cancelButton.isEnabled = isEditing
        
        let constant: CGFloat = isEditing ? 20 : view.bounds.width/2 - saveButton.bounds.width/2
        let saveConstraint = NSLayoutConstraint(item: saveButton as Any, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: constant)
        let cancelConstraint = NSLayoutConstraint(item: cancelButton as Any, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: isEditing ? view.bounds.width - 20 - cancelButton.bounds.width : constant)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: { [self] in
            view.removeConstraint(saveButtonLeadingConstraint)
            view.addConstraint(saveConstraint)
            view.removeConstraint(cancelButtonLeadingConstant)
            view.addConstraint(cancelConstraint)
            view.layoutIfNeeded()
            if state != .isLoading {
                isEditing ? cancelButton.fadeIn() : cancelButton.fadeOut()
                saveButton.setTitle(isEditing ? "Сохранить" : "Редактировать", for: .normal)
            }
        })
        
        saveButtonLeadingConstraint = saveConstraint
        cancelButtonLeadingConstant = cancelConstraint
        if state != .isLoading {
            date = ""
        }
    }
    
    private func updateFields() {
        firstNameTextField.text = profile.firstName
        secondNameTextField.text = profile.secondName
        lastNameTextField.text = profile.lastName
        birthTextField.text = formatDateForClient(from: profile.birthday)
        date = ""
        emailTextField.text = profile.email
    }
    
    @IBAction private func textDidChange(sender: UITextField) {
        if let text = sender.text, text.count > 0, text.count < 25 {
            sender.layer.borderColor = UIColor.gray.cgColor
            sender.layer.borderWidth = 0.15
            textFieldsWithError[sender] = false
        } else {
            sender.layer.borderColor = UIColor.systemRed.cgColor
            sender.layer.borderWidth = 0.5
            textFieldsWithError[sender] = true
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
        PopUp.displayChoice(with: "Подтверждние действия", description: "Вы действительно хотите выйти?", confirmText: "Да", declineText: "Нет") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
            SwiftEntryKit.dismiss()
            NavigationService.loadAuth()
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case myCarsSegueCode:
                let navVC = segue.destination as! UINavigationController
                let destinationVC = navVC.topViewController as! WithUserInfo
                destinationVC.setUser(info: user)
            case settingsSegueCode:
                let navVC = segue.destination as! UINavigationController
                let settingsVC = navVC.topViewController as! WithUserInfo
                settingsVC.setUser(info: user)
            default: return
        }
    }
}

//MARK: - Update user information logic
extension MyProfileViewController {
    private func updateUserInfo() {
        guard hasChanges else {
            state = .none
            return
        }
        
        guard textFieldsWithError.allSatisfy({ !$0.value }) else {
            PopUp.displayMessage(with: "Неккоректные данные", description: "Проверьте введенную информацию!", buttonText: "Ок")
            return
        }
        
        state = .isLoading
        NetworkService.shared.makePostRequest(page: RequestPath.Profile.editProfile, params: buildRequestParams(), completion: completion)
    }
    
    private func buildRequestParams() -> [URLQueryItem] {
        var params: [URLQueryItem] = [URLQueryItem(name: RequestKeys.Auth.userId, value: user.getId)]
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.firstName, value: firstNameTextField.text))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.secondName, value: secondNameTextField.text))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.lastName, value: lastNameTextField.text))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.email, value: emailTextField.text))
        params.append(URLQueryItem(name: RequestKeys.PersonalInfo.birthday, value: birthTextField.text))
        return params
    }
    
    private func completion(response: Response?) {
        DispatchQueue.main.async { [self] in
            if let success = response, success.errorCode == nil, success.result == "ok" {
                user.update(Person(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, secondName: secondNameTextField.text!, email: emailTextField.text!, birthday: birthTextField.text!))
                PopUp.displayMessage(with: "Успех", description: "Личная информация успешно обновлена", buttonText: "Ок")
                state = .none
            } else {
                PopUp.displayMessage(with: "Ошибка", description: "Произошла ошибка при сохранении данных, повторите попытку позже", buttonText: "Ок")
                state = .isEditing
            }
        }
    }
}

//MARK: - WithUserInfo
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
