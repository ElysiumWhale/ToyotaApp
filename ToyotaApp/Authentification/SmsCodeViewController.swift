import UIKit

class SmsCodeViewController: UIViewController {

    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var smsCodeTextField: UITextField!
    @IBOutlet var sendSmsCodeButton: UIButton!
    @IBOutlet var wrongCodeLabel: UILabel!
    @IBOutlet var activitySwitcher: UIActivityIndicatorView!
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
        if smsCodeTextField!.text!.count == 4 {
            sendSmsCodeButton?.isHidden = true
            activitySwitcher?.startAnimating()
            activitySwitcher?.isHidden = false
            view.endEditing(true)
            
            NetworkService.shared.makePostRequest(page: PostRequestPath.checkCode, params: [URLQueryItem(name: PostRequestKeys.phoneNumber, value: phoneNumber),
                 URLQueryItem(name: PostRequestKeys.code, value: smsCodeTextField!.text),
                 URLQueryItem(name: PostRequestKeys.brandId, value: Brand.id)],
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
    func loadStoryboard(with name: String, controller: String, configure: @escaping (UIViewController) -> Void = {_ in }) {
        DispatchQueue.main.async {
            let storyBoard: UIStoryboard = UIStoryboard(name: name, bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: controller)
            configure(vc)
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumberLabel?.text = phoneNumber
    }
}

//MARK: - Callback for request
extension SmsCodeViewController {
    private var completion: (Data?) -> Void {
        { [self] data in
            if let data = data {
                do {
                    let rawFeed = try JSONDecoder().decode(SmsCodeDidSendResponse.self, from: data)
                    
                    UserDefaults.standard.setValue(rawFeed.secrectKey, forKey: DefaultsKeys.secretKey)
                    UserDefaults.standard.setValue(rawFeed.userId, forKey: DefaultsKeys.userId)
                    
                    Debug.userId = rawFeed.userId
                    Debug.secretKey = rawFeed.secrectKey
                    
                    if rawFeed.registeredUser != nil {
                        navigateToRegister(page: rawFeed.registerPage!)
                    } else {
                        loadStoryboard(with: AppStoryboards.register, controller: AppViewControllers.registerNavigation)
                    }
                }
                catch let decodeError as NSError {
                    print("Decoder error: \(decodeError.localizedDescription)")
                    DispatchQueue.main.async {
                        wrongCodeLabel.isHidden = false
                        activitySwitcher?.stopAnimating()
                        sendSmsCodeButton?.isHidden = false
                        smsCodeTextField?.layer.borderColor = UIColor.systemRed.cgColor
                        smsCodeTextField?.layer.borderWidth = 1.0
                    }
                }
            }
        }
    }
    
    private func navigateToRegister(page: Int) {
        switch page {
            case 1: loadStoryboard(with: AppStoryboards.register, controller: AppViewControllers.registerNavigation)
            case 2: loadStoryboard(with: AppStoryboards.register, controller: AppViewControllers.dealerViewController)
            case 3: loadStoryboard(with: AppStoryboards.register, controller: AppViewControllers.addingCarViewController)
            case 4: loadStoryboard(with: AppStoryboards.main, controller: AppViewControllers.mainMenuTabBarController)
            default: print(page); return
        }
    }
}
