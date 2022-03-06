import UIKit

class SmsCodeViewController: UIViewController {
    @IBOutlet private var phoneNumberLabel: UILabel!
    @IBOutlet private var smsCodeTextField: InputTextField!
    @IBOutlet private var sendSmsCodeButton: KeyboardBindedButton!
    @IBOutlet private var wrongCodeLabel: UILabel!
    @IBOutlet private var activitySwitcher: UIActivityIndicatorView!

    private var phoneNumber: String!
    private var type: AuthType = .register

    private lazy var registerHandler: RequestHandler<CheckUserOrSmsCodeResponse> = {
        RequestHandler<CheckUserOrSmsCodeResponse>()
            .observe(on: .main)
            .bind { data in
                KeychainManager.set(UserId(data.userId!))
                KeychainManager.set(SecretKey(data.secretKey))
                NavigationService.resolveNavigation(with: CheckUserContext(response: data)) {
                    NavigationService.loadRegister(.error(message: .error(.serverBadResponse)))
                }
            } onFailure: { [weak self] error in
                self?.handle(error)
            }
    }()

    private lazy var changeNumberHandler: RequestHandler<SimpleResponse> = {
        RequestHandler<SimpleResponse>()
            .observe(on: .main)
            .bind { [weak self] _ in
                self?.handleSuccess()
            } onFailure: { [weak self] error in
                self?.handle(error)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        wrongCodeLabel.alpha = 0
        view.hideKeyboardWhenSwipedDown()
        sendSmsCodeButton.bindToKeyboard()
    }

    func configure(with authType: AuthType, and number: String) {
        type = authType
        phoneNumber = number
    }

    @IBAction func codeValueDidChange(with sender: UITextField) {
        wrongCodeLabel.fadeOut(0.3)
        smsCodeTextField.toggle(state: .normal)
    }

    private func displayError() {
        wrongCodeLabel.fadeIn(0.3)
        activitySwitcher.stopAnimating()
        sendSmsCodeButton.fadeIn(0.3)
        smsCodeTextField.toggle(state: .error)
    }
}
// MARK: - Navigation
extension SmsCodeViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumberLabel.text = phoneNumber
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        // parent == nil means that controller will be popped (backward navigation)
        if parent == nil {
            NetworkService.makeRequest(page: .registration(.deleteTemp),
                                       params: [(.personalInfo(.phoneNumber), phoneNumber)])
        }
    }
}

// MARK: - Request handling
extension SmsCodeViewController {
    @IBAction func login(with sender: UIButton) {
        guard smsCodeTextField.text?.count == 4 else {
            displayError()
            return
        }
        sendSmsCodeButton.fadeOut()
        activitySwitcher.startAnimating()
        view.endEditing(true)

        switch type {
            case .register:
                NetworkService.makeRequest(page: .registration(.checkCode),
                                           params: buildRequestParams(authType: type),
                                           handler: registerHandler)
            case .changeNumber:
                NetworkService.makeRequest(page: .setting(.changePhone),
                                           params: buildRequestParams(authType: type),
                                           handler: changeNumberHandler)
        }
    }

    private func buildRequestParams(authType: AuthType) -> RequestItems {
        var params: RequestItems = [(.personalInfo(.phoneNumber), phoneNumber),
                                    (.auth(.code), smsCodeTextField!.text)]
        params.append(authType == .register ? (.auth(.brandId), Brand.Toyota)
                                            : (.auth(.userId), KeychainManager<UserId>.get()?.id))
        return params
    }

    private func handle(_ error: ErrorResponse) {
        activitySwitcher.stopAnimating()
        sendSmsCodeButton.fadeIn()
        PopUp.display(.error(description: error.message ?? .error(.unknownError)))
    }

    private func handleSuccess() {
        if case .changeNumber(let notificator) = type {
            notificator.notificateObservers()
            PopUp.display(.success(description: .common(.phoneChanged)))
            navigationController?.dismiss(animated: true)
        }
    }
}
