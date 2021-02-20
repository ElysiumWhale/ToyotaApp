import UIKit
import SwiftEntryKit

class MyProfileViewController: UIViewController {
    @IBOutlet private(set) var firstNameTextField: UITextField!
    @IBOutlet private(set) var secondNameTextField: UITextField!
    @IBOutlet private(set) var lastNameTextField: UITextField!
    @IBOutlet private(set) var birthTextField: UITextField!
    @IBOutlet private(set) var emailTextField: UITextField!
    @IBOutlet private(set) var cancelButton: UIButton!
    @IBOutlet private(set) var saveButton: UIButton!
    
    private let myCarsSegueCode = SegueIdentifiers.MyProfileToCars
    
    private var userInfo: UserInfo!
    private var isPersonEditing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        let person = userInfo.person
        firstNameTextField.text = person.firstName
        secondNameTextField.text = person.secondName
        lastNameTextField.text = person.lastName
        birthTextField.text = person.birthday
        emailTextField.text = person.email
    }
    
    @IBAction func enterEditMode(sender: UIButton) {
        isPersonEditing = !isPersonEditing
        if isPersonEditing {
            saveButton.setTitle("Сохранить", for: .normal)
        } else {
            #warning("to-do: save profile query + push to user defaults")
            saveButton.setTitle("Редактировать", for: .normal)
        }
        switchEditingMode(with: isPersonEditing)
    }
    
    @IBAction func cancelEdit(sender: UIButton) {
        saveButton.setTitle("Редактировать", for: .normal)
        isPersonEditing = false
        switchEditingMode(with: isPersonEditing)
    }
    
    private func switchEditingMode(with: Bool) {
        firstNameTextField.isEnabled = with
        secondNameTextField.isEnabled = with
        lastNameTextField.isEnabled = with
        birthTextField.isEnabled = with
        emailTextField.isEnabled = with
        cancelButton.isEnabled = with
        cancelButton.isHidden = !with
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
                destinationVC.setUser(info: userInfo!)
            default: return
        }
    }
}

//MARK: - WithUserInfo
extension MyProfileViewController: WithUserInfo {
    func setUser(info: UserInfo) {
        userInfo = info
    }
}
