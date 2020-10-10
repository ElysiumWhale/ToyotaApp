import UIKit

class SmsCodeViewController: UIViewController {

    @IBOutlet var phoneNumberLabel: UILabel?
    
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(with sender: UIButton) {
        //send sms code
        //recieve struct:
            //first time flag: 0/1
            //auth key: id + ddmmyyhhmmss + salt
        //send auth key
        //store auth key
        //if first time
        let isFirstTimeAuth = "1".contains("1")
        if isFirstTimeAuth {
            loadStoryboard(with: AppStoryboards.register.rawValue, controller: AppViewControllers.registerNavigation.rawValue, configure: {_ in })
        } else {
            loadStoryboard(with: AppStoryboards.main.rawValue, controller: AppViewControllers.mainMenuNavigation.rawValue, configure: {_ in})
        }
    }
}
//MARK: - Navigation
extension SmsCodeViewController {
    func loadStoryboard(with name: String, controller: String, configure: (UIViewController) -> Void) {
        let storyBoard: UIStoryboard = UIStoryboard(name: name, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: controller)
        configure(vc)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumberLabel?.text = phoneNumber
    }
}
