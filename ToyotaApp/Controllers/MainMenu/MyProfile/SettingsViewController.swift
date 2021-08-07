import UIKit
import SwiftEntryKit

class SettingsViewController: UIViewController {
    @IBOutlet var phoneTextField: UITextField!
    
    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextField.text = user.getPhone
    }
    
    @IBAction func changeNumber(sender: Any?) {
        PopUp.displayChoice(with: "Подтверждение",
                            description: "Вы действительно хотите изменить номер телефона?",
                            confirmText: CommonText.yes, declineText: CommonText.cancel) { [self] in
            SwiftEntryKit.dismiss()
            NavigationService.loadAuth(from: navigationController!, with: user.getNotificator)
        }
    }
    
    @IBAction func doneDidPress(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension SettingsViewController: WithUserInfo {
    func subscribe(on proxy: UserProxy) {
        proxy.getNotificator.add(observer: self)
    }
    
    func unsubscribe(from proxy: UserProxy) {
        proxy.getNotificator.remove(obsever: self)
    }
    
    func userDidUpdate() { }
    
    func setUser(info: UserProxy) {
        user = info
    }
}
