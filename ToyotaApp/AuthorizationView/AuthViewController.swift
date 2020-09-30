import UIKit

class AuthViewController: UIViewController {

    @IBOutlet var userName: UITextField?
    
    @IBOutlet var password: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func login(with sender: UIButton) {
        // if auth is success
        loadHomeScreen()
    }

    func loadHomeScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainMenuVC = storyBoard.instantiateViewController(withIdentifier: "MainMenuNavigationController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainMenuVC)
    }
}
