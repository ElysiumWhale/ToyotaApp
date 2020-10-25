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
        wrongCodeLabel.isHidden = true
        smsCodeTextField?.layer.borderWidth = 0
    }
    
    @IBAction func login(with sender: UIButton) {
        if !smsCodeTextField!.text!.isEmpty {
            NetworkService.shared.makePostRequest(page: PostRequestPath.smsCode, params: [URLQueryItem(name: PostRequestKeys.phoneNumber, value: phoneNumber),
                 URLQueryItem(name: PostRequestKeys.code, value: smsCodeTextField!.text)],
                completion: completion)
        } else {
            smsCodeTextField?.layer.borderColor = UIColor.systemRed.cgColor
            smsCodeTextField?.layer.borderWidth = 1.0
            wrongCodeLabel.isHidden = false
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
                    let rawFeed = try JSONDecoder().decode(SmsCodeDidSendResponse.self, from: data)
                    //TODO: UserDefaults.standard.setValue(rawFeed.authKey, forKey: DefaultsKeys.authKey)
                    #warning("Line is commented while debug")
                    //UserDefaults.standard.set(rawFeed.user_id, forKey: DefaultsKeys.userId)
                    DebugUserId.userId = rawFeed.user_id
                    if rawFeed.result == 1 {
                        DispatchQueue.main.async {
                            loadStoryboard(with: AppStoryboards.register, controller: AppViewControllers.registerNavigation)
                        }
                    } else {
                        DispatchQueue.main.async {
                            loadStoryboard(with: AppStoryboards.main, controller: AppViewControllers.mainMenuTabBarController)
                        }
                    }
                }
                catch let decodeError as NSError {
                    print("Decoder error: \(decodeError.localizedDescription)")
                    DispatchQueue.main.async {
                        wrongCodeLabel.isHidden = false
                        smsCodeTextField?.layer.borderColor = UIColor.systemRed.cgColor
                        smsCodeTextField?.layer.borderWidth = 1.0
                    }
                }
            }
        }
    }
}
