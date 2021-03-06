import UIKit
import SwiftEntryKit

class SettingsViewController: UIViewController {
    @IBOutlet var phoneTextField: UITextField!
    
    private var user: UserProxy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextField.text = user.getPhone
    }
    
    @IBAction func changeNumber(sender: Any?) {
        PopUp.displayChoice(with: "Подтверждение", description: "Вы действительно хотите изменить номер телефона?", confirmText: "Да", declineText: "Отмена") { [self] in
            SwiftEntryKit.dismiss()
        }
    }
}

extension SettingsViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}
