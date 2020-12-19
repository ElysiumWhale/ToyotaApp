import UIKit

class MyProfileViewController: UIViewController {
    
    @IBOutlet private(set) var firstNameTextField: UITextField!
    @IBOutlet private(set) var secondNameTextField: UITextField!
    @IBOutlet private(set) var lastNameTextField: UITextField!
    @IBOutlet private(set) var birthTextField: UITextField!
    @IBOutlet private(set) var emailTextField: UITextField!
    @IBOutlet private(set) var cancelButton: UIButton!
    @IBOutlet private(set) var saveButton: UIButton!
    
    private let myCarsSegueCode = SegueIdentifiers.MyProfileToCars
    
    private var userInfo: UserInfo?
    private var isPersonEditing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.sizeToFit()
        if let user = userInfo {
            firstNameTextField.text = user.person.firstName
            secondNameTextField.text = user.person.secondName
            lastNameTextField.text = user.person.lastName
            birthTextField.text = user.person.birthday
            emailTextField.text = user.person.email
        } else {
            firstNameTextField.text = "Mock"
            secondNameTextField.text = "Mock"
            lastNameTextField.text = "Mock"
            birthTextField.text = "21.05.78"
            emailTextField.text = "mock.mock@mock.mock"
        }
    }
    
    @IBAction func enterEditMode(sender: UIButton) {
        isPersonEditing = !isPersonEditing
        if isPersonEditing {
            saveButton.titleLabel!.text = "Сохранить"
        } else {
            saveButton.titleLabel!.text = "Редактировать"
        }
        firstNameTextField.isEnabled = isPersonEditing
        secondNameTextField.isEnabled = isPersonEditing
        lastNameTextField.isEnabled = isPersonEditing
        birthTextField.isEnabled = isPersonEditing
        emailTextField.isEnabled = isPersonEditing
        cancelButton.isEnabled = isPersonEditing
        cancelButton.isHidden = !isPersonEditing
    }
    
    @IBAction func cancelEdit(sender: UIButton) {
        firstNameTextField.isEnabled = false
        secondNameTextField.isEnabled = false
        lastNameTextField.isEnabled = false
        birthTextField.isEnabled = false
        emailTextField.isEnabled = false
        cancelButton.isEnabled = false
        cancelButton.isHidden = true
    }
    
    @IBAction func logout(sender: Any?) {
        PopUpPreset.display(with: "Выход из аккаунта", description: "Вы действительно хотите выйти?", buttonText: "Нет")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case myCarsSegueCode:
                let destinationVC = segue.destination as? MyCarsViewController
                destinationVC?.configure(with: userInfo!.cars)
            default: return
        }
    }
}

extension MyProfileViewController: WithUserInfo {
    func setUser(info: UserInfo) {
        userInfo = info
    }
}
