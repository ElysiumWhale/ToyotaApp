import UIKit

class SmsCodeViewController: UIViewController {

    @IBOutlet var phoneNumberLabel: UILabel?
    @IBOutlet var smsCodeTextField: UITextField?
    @IBOutlet var sendSmsCodeButton: UIButton?
    
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func codeValueDidChange(with sender: UITextField) {
        if sender.text?.count == 4 {
            sendSmsCodeButton!.isEnabled = true
        }
    }
    
    @IBAction func login(with sender: UIButton) {
        if !smsCodeTextField!.text!.isEmpty {
//            NetworkService.shared.makePostRequest(page: PostRequests.smsCode, params: [URLQueryItem(name: PostRequests.phoneNumber, value: phoneNumber),
//                 URLQueryItem(name: PostRequests.smsCode, value: smsCodeLabel!.text)],
//                completion: completion)
            ///DEBUG
            loadStoryboard(with: AppStoryboards.main, controller: AppViewControllers.mainMenuTabBarController)
        } else {
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
                    let rawFeed = try JSONDecoder().decode(PhoneDidSendResponse.self, from: data)
                    #warning("Future release")
                    //UserDefaults.standard.setValue(rawFeed.authKey, forKey: DefaultsKeys.authKey)
                    UserDefaults.standard.setValue(rawFeed.authKey, forKey: DefaultsKeys.authKey)
                    if rawFeed.firstTimeFlag == 1 {
                        loadStoryboard(with: AppStoryboards.register, controller: AppViewControllers.registerNavigation)
                    } else {
                        loadStoryboard(with: AppStoryboards.main, controller: AppViewControllers.mainMenuTabBarController)
                    }
                }
                catch let decodeError as NSError {
                    print("Decoder error: \(decodeError.localizedDescription)")
                }
            }
        }
    }
}
