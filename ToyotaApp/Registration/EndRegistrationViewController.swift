import UIKit

class EndRegistrationViewController: UIViewController {
    
    @IBAction func loadMainMenu(sender: Any?) {
        DispatchQueue.main.async {
            let storyBoard: UIStoryboard = UIStoryboard(name: AppStoryboards.main, bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: AppViewControllers.mainMenuTabBarController)
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
