import UIKit

class MainMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logout(with sender: Any?) {
        //
        loadAuthScreen()
    }

    func loadAuthScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: AppStoryboards.auth.rawValue, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: AppViewControllers.authNavigation.rawValue)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }

}
