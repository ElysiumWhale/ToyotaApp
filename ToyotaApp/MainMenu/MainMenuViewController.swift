import UIKit

class MainMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logout(with sender: Any?) {
        //show dialog
        //send info about logout to server
        //NetworkService.shared.logout()
        loadAuthScreen()
    }

    func loadAuthScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: AppStoryboards.auth, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: AppViewControllers.authNavigation)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }

}
