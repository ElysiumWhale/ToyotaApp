import UIKit

class SmsCodeViewController: UIViewController {

    @IBOutlet var phoneNumberLabel: UILabel?
    @IBOutlet var smsCodeTextField: UITextField?
    @IBOutlet var sendSmsCodeButton: UIButton?
    @IBOutlet var wrongCodeLabel: UILabel!
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func codeValueDidChange(with sender: UITextField) {
        if sender.text?.count == 4 {
            sendSmsCodeButton!.isEnabled = true
        }
        wrongCodeLabel.isHidden = false
        smsCodeTextField?.layer.borderWidth = 0
    }
    
    @IBAction func login(with sender: UIButton) {
        if !smsCodeTextField!.text!.isEmpty {
            NetworkService.shared.makePostRequest(page: PostRequests.smsCode, params: [URLQueryItem(name: PostRequests.phoneNumber, value: phoneNumber),
                 URLQueryItem(name: PostRequests.smsCode, value: smsCodeTextField!.text)],
                completion: completion)
            ///DEBUG
//            loadStoryboard(with: AppStoryboards.main, controller: AppViewControllers.mainMenuTabBarController)
        } else {
            smsCodeTextField?.layer.borderColor = UIColor.systemRed.cgColor
            smsCodeTextField?.layer.borderWidth = 1.0
            #warning("Need to enter code")
        }
    }
}
//MARK: - Navigation
extension SmsCodeViewController {
    func loadStoryboard(with name: String, controller: String, configure: (UIViewController) -> Void = {_ in }) {
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

//MARK: - Callback for request
extension SmsCodeViewController {
    var completion: (Data?) -> Void {
        { [self] data in
            if let data = data {
                do {
                    #warning("CHECK FOR CORRECT CODE")
                    let rawFeed = try JSONDecoder().decode(PhoneDidSendResponse.self, from: data)
                    #warning("Future release")
                    //UserDefaults.standard.setValue(rawFeed.authKey, forKey: DefaultsKeys.authKey)
                    UserDefaults.standard.set(rawFeed.id, forKey: DefaultsKeys.userId)
                    if rawFeed.firstTimeFlag == 1 {
                        loadStoryboard(with: AppStoryboards.register, controller: AppViewControllers.registerNavigation)
                    } else {
                        loadStoryboard(with: AppStoryboards.main, controller: AppViewControllers.mainMenuTabBarController)
                    }
                }
                catch let decodeError as NSError {
                    print("Decoder error: \(decodeError.localizedDescription)")
                    wrongCodeLabel.isHidden = false
                    smsCodeTextField?.layer.borderColor = UIColor.systemRed.cgColor
                    smsCodeTextField?.layer.borderWidth = 1.0
                }
            }
        }
    }
}
