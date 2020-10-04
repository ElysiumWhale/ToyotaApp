import UIKit
import PhoneNumberKit

class AuthViewController: UIViewController {
    
    @IBOutlet var phoneNumber: PhoneNumberTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func login(with sender: UIButton) {
        // if auth is success
        loadHomeScreen()
    }

    func loadHomeScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: AppStoryboards.main.rawValue, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: AppViewControllers.mainMenuNavigation.rawValue)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }
}
