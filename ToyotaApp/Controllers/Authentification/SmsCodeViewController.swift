import UIKit

class SmsCodeViewController: UIViewController {
    @IBOutlet private var phoneNumberLabel: UILabel!
    @IBOutlet private var smsCodeTextField: UITextField!
    @IBOutlet private var sendSmsCodeButton: UIButton!
    @IBOutlet private var wrongCodeLabel: UILabel!
    @IBOutlet private var activitySwitcher: UIActivityIndicatorView!
    
    private var phoneNumber: String!
    private var type: AuthType = .first
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(with authType: AuthType, and number: String) {
        type = authType
        phoneNumber = number
    }
    
    @IBAction func codeValueDidChange(with sender: UITextField) {
        if sender.text?.count == 4 {
            sendSmsCodeButton!.isEnabled = true
        }
        wrongCodeLabel.isHidden = true
        smsCodeTextField?.layer.borderWidth = 0
    }
    
    @IBAction func login(with sender: UIButton) {
        guard smsCodeTextField.text?.count == 4 else {
            displayError()
            return
        }
        sendSmsCodeButton.isHidden = true
        activitySwitcher.startAnimating()
        activitySwitcher.isHidden = false
        view.endEditing(true)
        
        switch type {
            case .first:
                NetworkService.shared.makePostRequest(page: RequestPath.Registration.checkCode, params:
                    [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber),
                     URLQueryItem(name: RequestKeys.Auth.code, value: smsCodeTextField!.text),
                     URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.id)],
                    completion: completion)
            case .changeNumber:
                NetworkService.shared.makePostRequest(page: RequestPath.Settings.changePhone, params:
                    [URLQueryItem(name: RequestKeys.Auth.userId, value: DefaultsManager.getUserInfo(UserId.self)!.id),
                     URLQueryItem(name: RequestKeys.Auth.code, value: smsCodeTextField!.text),
                     URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber)],
                    completion: changeNumberCompletion)
        }
    }
}
//MARK: - Navigation
extension SmsCodeViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumberLabel.text = phoneNumber
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        let isPopping = parent == nil
        if isPopping {
            NetworkService.shared.makeSimpleRequest(page: RequestPath.Registration.deleteTemp, params: [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber)])
        }
    }
}

//MARK: - Callbacks for requests
extension SmsCodeViewController {
    private func completion(response: CheckUserOrSmsCodeResponse?) -> Void {
        guard let response = response else {
            displayError()
            return
        }
        DefaultsManager.pushUserInfo(info: UserId(response.userId!))
        DefaultsManager.pushUserInfo(info: SecretKey(response.secretKey))
        NavigationService.resolveNavigation(with: response, fallbackCompletion: NavigationService.loadRegister)
    }
    
    private func changeNumberCompletion(response: Response?) -> Void {
        guard let response = response, response.errorCode == nil, case .changeNumber(let proxy) = type else {
            displayError()
            return
        }
        DefaultsManager.pushUserInfo(info: Phone(phoneNumber!))
        DispatchQueue.main.async { [self] in
            proxy.notificateObservers()
            navigationController?.dismiss(animated: true) {
                PopUp.displayMessage(with: "Подтверждение", description: "Телефон упешно изменен", buttonText: "Ок")
            }
        }
    }
    
    private func displayError() {
        DispatchQueue.main.async { [self] in
            wrongCodeLabel.isHidden = false
            activitySwitcher.stopAnimating()
            sendSmsCodeButton.isHidden = false
            smsCodeTextField.layer.borderColor = UIColor.systemRed.cgColor
            smsCodeTextField.layer.borderWidth = 1.0
        }
    }
}
