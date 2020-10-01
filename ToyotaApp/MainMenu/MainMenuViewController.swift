import UIKit

class MainMenuViewController: UIViewController {
    
    @IBOutlet var myCarButton: UIButton!
    
    @IBOutlet var techButton: UIButton!
    
    @IBOutlet var serviceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCarButton.layer.cornerRadius = 10
        myCarButton.clipsToBounds = true
        techButton.layer.cornerRadius = 10
        techButton.clipsToBounds = true
        serviceButton.layer.cornerRadius = 10
        serviceButton.clipsToBounds = true
    }
    
    @IBAction func logout(with sender: Any?) {
        //
        loadAuthScreen()
    }

    func loadAuthScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: AppStoryboards.auth.rawValue, bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: AppViewControllers.auth.rawValue)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(viewController)
    }

}
