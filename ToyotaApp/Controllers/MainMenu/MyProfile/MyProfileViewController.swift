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
    
    private let datePicker: UIDatePicker = UIDatePicker()
    private var date: String = "" {
        didSet { view.endEditing(true) }
    }
    
    private let myCarsSegueCode = SegueIdentifiers.MyProfileToCars
    private let settingsSegueCode = SegueIdentifiers.MyProfileToSettings
    
    private var user: UserProxy!
    private var profile: Person { user.getPerson }
    
    private var state: EditingStates = .none {
        didSet { switchInterface(state) }
    }
    
    private func switchInterface(_ state: EditingStates) {
        let isEditing = state == .isEditing
        for field in textFieldsWithError.keys {
            field.isEnabled = isEditing ? true : false
        }
        cancelButton.isEnabled = isEditing ? true : false
        if state != .isLoading {
            cancelButton.isHidden = !isEditing
            saveButton.setTitle(isEditing ? "Сохранить" : "Редактировать", for: .normal)
        }
    }
    
    private var textFieldsWithError: [UITextField : Bool]!
    
    private var hasChanges: Bool {
        profile.firstName != firstNameTextField.text ||
        profile.secondName != secondNameTextField.text ||
        profile.lastName != lastNameTextField.text ||
        profile.email != emailTextField.text ||
        profile.birthday != birthTextField.text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureDatePicker(datePicker, with: #selector(dateDidSelect), for: birthTextField)
        updateFields()
        textFieldsWithError = [firstNameTextField : false, secondNameTextField : false,
                               lastNameTextField : false, emailTextField : false, birthTextField : false]
    }
    
    func updateFields() {
        firstNameTextField.text = profile.firstName
        secondNameTextField.text = profile.secondName
        lastNameTextField.text = profile.lastName
        #warning("to-do: format data")
        birthTextField.text = profile.birthday
        emailTextField.text = profile.email
    }
    
    @IBAction func textDidChange(sender: UITextField) {
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
    
    func buildQueryParams() -> [URLQueryItem] {
        var items: [URLQueryItem] = [URLQueryItem(name: RequestKeys.Auth.userId, value: user.getId)]
        items.append(URLQueryItem(name: RequestKeys.PersonalInfo.firstName, value: firstNameTextField.text))
        items.append(URLQueryItem(name: RequestKeys.PersonalInfo.secondName, value: secondNameTextField.text))
        items.append(URLQueryItem(name: RequestKeys.PersonalInfo.lastName, value: lastNameTextField.text))
        items.append(URLQueryItem(name: RequestKeys.PersonalInfo.email, value: emailTextField.text))
        items.append(URLQueryItem(name: RequestKeys.PersonalInfo.birthday, value: birthTextField.text))
        return items
    }
    
    @IBAction func enterEditMode(sender: UIButton) {
        switch state {
            case .none: state = .isEditing
            case .isLoading: return
            case .isEditing: updateUserInfo()
        }
    }
    
    func updateUserInfo() {
        guard hasChanges else {
            state = .none
            return
        }
        
        guard textFieldsWithError.allSatisfy({ !$0.value }) else {
            PopUp.displayMessage(with: "Неккоректные данные", description: "Проверьте введенную информацию!", buttonText: "Ок")
            return
        }
        
        state = .isLoading
        NetworkService.shared.makePostRequest(page: RequestPath.Profile.editProfile, params: buildQueryParams(), completion: completion)
    }
    
    func completion(response: Response?) {
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
    
    @IBAction func cancelEdit(sender: UIButton) {
        if hasChanges {
            updateFields()
            for textField in textFieldsWithError.keys {
                textDidChange(sender: textField)
            }
        }
        state = .none
    }
    
    @IBAction func dateDidSelect(sender: Any?) {
        date = formatSelectedDate(from: datePicker, to: birthTextField)
    }
    
    @IBAction func logout(sender: Any?) {
        PopUp.displayChoice(with: "Выход из аккаунта", description: "Вы действительно хотите выйти?", confirmText: "Да", declineText: "Нет") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
            SwiftEntryKit.dismiss()
            NavigationService.loadAuth()
        }
    }
    
    // MARK: - Navigation
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

//MARK: - WithUserInfo
extension MyProfileViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}
