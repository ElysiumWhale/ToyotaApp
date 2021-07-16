import UIKit

class SmsCodeViewController: UIViewController {
    @IBOutlet private var phoneNumberLabel: UILabel!
    @IBOutlet private var smsCodeTextField: InputTextField!
    @IBOutlet private var sendSmsCodeButton: UIButton!
    @IBOutlet private var wrongCodeLabel: UILabel!
    @IBOutlet private var activitySwitcher: UIActivityIndicatorView!
    
    private var phoneNumber: String!
    private var type: AuthType = .register
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    func configure(with authType: AuthType, and number: String) {
        type = authType
        phoneNumber = number
    }
    
    @IBAction func codeValueDidChange(with sender: UITextField) {
        wrongCodeLabel.fadeOut(0.3)
        smsCodeTextField.toggleErrorState(hasError: false)
    }
    
    private func displayError() {
        DispatchQueue.main.async { [self] in
            wrongCodeLabel.fadeIn(0.3)
            activitySwitcher.stopAnimating()
            sendSmsCodeButton.fadeIn(0.3)
            smsCodeTextField.toggleErrorState(hasError: true)
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
        sendSmsCodeButton.fadeOut(0.3)
        activitySwitcher.startAnimating()
        view.endEditing(true)
        
        switch type {
            case .register:
                NetworkService.shared.makePostRequest(page: RequestPath.Registration.checkCode, params: buildRequestParams(authType: type), completion: registerCompletion)
            case .changeNumber:
                NetworkService.shared.makePostRequest(page: RequestPath.Settings.changePhone, params: buildRequestParams(authType: type), completion: changeNumberCompletion)
        }
    }
    
    private func buildRequestParams(authType: AuthType) -> [URLQueryItem] {
        var params = [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber),
                      URLQueryItem(name: RequestKeys.Auth.code, value: smsCodeTextField!.text)]
        params.append(authType == .register ? URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.Toyota)
                                            : URLQueryItem(name: RequestKeys.Auth.userId, value: DefaultsManager.getUserInfo(UserId.self)!.id))
        return params
    }
    
    private func registerCompletion(for response: Result<CheckUserOrSmsCodeResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                DefaultsManager.pushUserInfo(info: UserId(data.userId!))
                DefaultsManager.pushUserInfo(info: SecretKey(data.secretKey))
                NavigationService.resolveNavigation(with: data) { _ in NavigationService.loadRegister() }
            case .failure(let error):
                displayError(with: error.message ?? AppErrors.unknownError.rawValue) { [weak self] in
                    self?.activitySwitcher.stopAnimating()
                    self?.sendSmsCodeButton.fadeIn(0.3)
                }
        }
    }
    
    private func changeNumberCompletion(for response: Result<Response, ErrorResponse>) {
        switch response {
            case .success:
                if case .changeNumber(let notificator) = type {
                    notificator.notificateObservers()
                    dismissNavigationWithDispatch(animated: true) {
                        PopUp.displayMessage(with: "Подтверждение", description: "Телефон упешно изменен", buttonText: CommonText.ok)
                    }
                }
            case .failure(let error):
                displayError(with: error.message ?? AppErrors.unknownError.rawValue) { [weak self] in
                    self?.activitySwitcher.stopAnimating()
                    self?.sendSmsCodeButton.fadeIn(0.3)
                }
        }
    }
}
