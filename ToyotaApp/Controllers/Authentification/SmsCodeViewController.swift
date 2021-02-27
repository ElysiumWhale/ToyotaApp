import UIKit

class SmsCodeViewController: UIViewController {
    @IBOutlet private var phoneNumberLabel: UILabel!
    @IBOutlet private var smsCodeTextField: UITextField!
    @IBOutlet private var sendSmsCodeButton: UIButton!
    @IBOutlet private var wrongCodeLabel: UILabel!
    @IBOutlet private var activitySwitcher: UIActivityIndicatorView!
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
            
            NetworkService.shared.makePostRequest(page: RequestPath.Registration.checkCode, params: [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber),
                 URLQueryItem(name: RequestKeys.Auth.code, value: smsCodeTextField!.text),
                 URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.id)],
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumberLabel?.text = phoneNumber
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard parent != nil else { return }
        NetworkService.shared.makeSimpleRequest(page: RequestPath.Registration.deleteTemp, params: [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber)])
    }
}

//MARK: - Callback for request
extension SmsCodeViewController {
    private var completion: (CheckUserOrSmsCodeResponse?) -> Void {
        { [self] response in
            if let response = response {
                DefaultsManager.pushUserInfo(info: UserId(response.userId!))
                DefaultsManager.pushUserInfo(info: SecretKey(response.secretKey))
                NavigationService.resolveNavigation(with: response, fallbackCompletion: NavigationService.loadRegister)
            }
            else {
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
