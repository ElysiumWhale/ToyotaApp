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
    
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard parent == nil else { return }
        NetworkService.shared.makeSimplePostRequest(page: RequestPath.Registration.deleteTemp, params: [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber)])
    }
}

//MARK: - Callback for request
extension SmsCodeViewController {
    private var completion: (CheckUserOrSmsCodeResponse?) -> Void {
        { [self] response in
            if let response = response {
                    let defaults = UserDefaults.standard
                    defaults.setValue(response.secretKey, forKey: DefaultsKeys.secretKey)
                    defaults.setValue(response.userId!, forKey: DefaultsKeys.userId)
                    defaults.setValue(true, forKeyPath: DefaultsKeys.isAuth)
                    
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
