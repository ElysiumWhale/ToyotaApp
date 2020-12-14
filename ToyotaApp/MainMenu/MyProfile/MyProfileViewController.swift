import UIKit

class MyProfileViewController: UIViewController {
    
    @IBOutlet private(set) var firstNameTextField: UITextField!
    @IBOutlet private(set) var secondNameTextField: UITextField!
    @IBOutlet private(set) var lastNameTextField: UITextField!
    @IBOutlet private(set) var birthTextField: UITextField!
    @IBOutlet private(set) var emailTextField: UITextField!
    @IBOutlet private(set) var cancelButton: UIButton!
    @IBOutlet private(set) var saveButton: UIButton!
    
    private var userInfo: UserInfo?
    
    private var isPersonEditing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.text = "Иван"
        secondNameTextField.text = "Иванович"
        lastNameTextField.text = "Иванов"
        birthTextField.text = "21.05.78"
        emailTextField.text = "ivanov.ivan@ivan.ru"
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension MyProfileViewController: WithUserInfo {
    func setUser(info: UserInfo) {
        userInfo = info
    }
}
