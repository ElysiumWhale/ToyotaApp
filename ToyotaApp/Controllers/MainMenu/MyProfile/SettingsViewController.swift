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
        phoneTextField.text = user.getPhone
    }

    @IBAction func changeNumber(sender: Any?) {
        PopUp.displayChoice(with: .common(.confirmation),
                            description: .question(.changeNumber),
                            confirmText: .common(.yes), declineText: .common(.cancel)) { [self] in
            NavigationService.loadAuth(from: navigationController!, with: user.getNotificator)
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
