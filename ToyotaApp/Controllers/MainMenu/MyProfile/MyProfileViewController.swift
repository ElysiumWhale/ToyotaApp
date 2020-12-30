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
        if let user = userInfo {
            firstNameTextField.text = user.person.firstName
            secondNameTextField.text = user.person.secondName
            lastNameTextField.text = user.person.lastName
            birthTextField.text = user.person.birthday
            emailTextField.text = user.person.email
        } else {
            PopUpPreset.display(with: "Ошибка", description: "...", buttonText: "Ок")
        }
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
    
    func switchEditingMode(with: Bool) {
        firstNameTextField.isEnabled = with
        secondNameTextField.isEnabled = with
        lastNameTextField.isEnabled = with
        birthTextField.isEnabled = with
        emailTextField.isEnabled = with
        cancelButton.isEnabled = with
        cancelButton.isHidden = !with
    }
    
    @IBAction func logout(sender: Any?) {
        #warning("to-do: logout + clean memory")
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

//MARK: - WithUserInfo
extension MyProfileViewController: WithUserInfo {
    func setUser(info: UserInfo) {
        userInfo = info
    }
}
