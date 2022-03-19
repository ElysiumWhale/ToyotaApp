import UIKit
import SwiftEntryKit

class SettingsViewController: UIViewController {
    @IBOutlet private var phoneTextField: InputTextField!
    @IBOutlet private var agreementButton: CustomizableButton!

    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextField.text = user.phone
    }

    @IBAction func changeNumber(sender: Any?) {
        PopUp.displayChoice(with: .common(.confirmation),
                            description: .question(.changeNumber),
                            confirmText: .common(.yes), declineText: .common(.cancel)) { [self] in
            let module = AuthFlow.authModule(authType: .changeNumber(with: user.notificator))
            navigationController?.pushViewController(module, animated: true)
        }
    }

    @IBAction func doneDidPress(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func agreementDidPress(_ sender: Any?) {
        let vc: UIViewController = UIStoryboard(.auth).instantiate(.agreement)
        present(vc, animated: true)
    }
}

extension SettingsViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}
