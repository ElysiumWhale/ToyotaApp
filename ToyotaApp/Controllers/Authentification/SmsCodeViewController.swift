import UIKit

class SmsCodeViewController: UIViewController {
    @IBOutlet private var phoneNumberLabel: UILabel!
    @IBOutlet private var smsCodeTextField: UITextField!
    @IBOutlet private var sendSmsCodeButton: UIButton!
    @IBOutlet private var wrongCodeLabel: UILabel!
    @IBOutlet private var activitySwitcher: UIActivityIndicatorView!
    
    private var phoneNumber: String!
    private var type: AuthType = .register
    
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
//MARK: - Navigation
extension SmsCodeViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumberLabel.text = phoneNumber
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        //parent == nil means that controller will be popped (backward navigation)
        if parent == nil {
            NetworkService.shared.makeSimpleRequest(page: RequestPath.Registration.deleteTemp, params: [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber)])
        }
    }
}

//MARK: - Request handling
extension SmsCodeViewController {
    @IBAction func login(with sender: UIButton) {
        guard smsCodeTextField.text?.count == 4 else {
            displayError()
            return
        }
        sendSmsCodeButton.isHidden = true
        activitySwitcher.startAnimating()
        view.endEditing(true)
        
        switch type {
            case .register:
                NetworkService.shared.makePostRequest(page: RequestPath.Registration.checkCode, params: buildRequestParams(authType: type), completion: registerCompletion)
            case .changeNumber(_):
                NetworkService.shared.makePostRequest(page: RequestPath.Settings.changePhone, params: buildRequestParams(authType: type), completion: changeNumberCompletion)
        }
    }
    
    private func buildRequestParams(authType: AuthType) -> [URLQueryItem] {
        var params = [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber),
                      URLQueryItem(name: RequestKeys.Auth.code, value: smsCodeTextField!.text)]
        if case .register = authType {
            params.append(URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.Toyota))
        } else {
            params.append(URLQueryItem(name: RequestKeys.Auth.userId, value: DefaultsManager.getUserInfo(UserId.self)!.id))
        }
        return params
    }
    
    private func registerCompletion(for response: Result<CheckUserOrSmsCodeResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                DefaultsManager.pushUserInfo(info: UserId(data.userId!))
                DefaultsManager.pushUserInfo(info: SecretKey(data.secretKey))
                NavigationService.resolveNavigation(with: data) { _ in NavigationService.loadRegister() }
            case .failure(let error):
                displayError(with:  error.message ?? AppErrors.unknownError.rawValue) { [self] in
                    activitySwitcher.stopAnimating()
                    sendSmsCodeButton.isHidden = false
                }
        }
    }
    
    #warning("todo: server must generate new secret key")
    private func changeNumberCompletion(for response: Result<Response, ErrorResponse>) {
        switch response {
            case .success(let data):
                if case .changeNumber(let notificator) = type, data.result == "ok" {
                    notificator.notificateObservers()
                    dismissNavigationWithDispatch(animated: true) {
                        PopUp.displayMessage(with: "Подтверждение", description: "Телефон упешно изменен", buttonText: CommonText.ok)
                    }
                } else {
                    displayError(with: "Что то пошло не так... Попробуйте провести операцию смены номера, перезайдя в настройки") { [self] in
                        activitySwitcher.stopAnimating()
                        sendSmsCodeButton.isHidden = false
                    }
                }
            case .failure(let error):
                displayError(with: error.message ?? AppErrors.unknownError.rawValue) { [self] in
                    activitySwitcher.stopAnimating()
                    sendSmsCodeButton.isHidden = false
                }
        }
    }
}
