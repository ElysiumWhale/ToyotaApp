import UIKit

class AuthViewController: UIViewController {
    @IBOutlet private var phoneNumber: PhoneTextField!
    @IBOutlet private var incorrectLabel: UILabel!
    @IBOutlet private var informationLabel: UILabel!
    @IBOutlet private var sendPhoneButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    
    private var type: AuthType = .register
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        hideKeyboardWhenTappedAround()
    }
    
    func configure(with authType: AuthType) {
        type = authType
    }
    
    func configureTextField() {
        if case .changeNumber(_) = type {
            informationLabel.text = "Введите новый номер:"
        }
    }
    
    @IBAction func phoneNumberDidChange(sender: UITextField) {
        incorrectLabel.fadeOut(0.3)
        phoneNumber.toggleErrorState(hasError: false)
    }
}

//MARK: - Navigation
extension AuthViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                let destinationVC = segue.destination as! SmsCodeViewController
                destinationVC.configure(with: type, and: phoneNumber.phone!)
                indicator.stopAnimating()
            default: return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sendPhoneButton.fadeIn(0.3)
    }
}

//MARK: - SegueWiRhRequestController
extension AuthViewController: SegueWithRequestController {
    typealias TResponse = Response
    
    var segueCode: String { SegueIdentifiers.NumberToCode }
    
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard let phone = phoneNumber.validPhone else {
            phoneNumber.toggleErrorState(hasError: true)
            incorrectLabel.fadeIn(0.3)
            return
        }
        
        sendPhoneButton.fadeOut(0.3)
        indicator.startAnimating()
        view.endEditing(true)
        if case .register = type {
            KeychainManager.set(Phone(phone))
        }
        NetworkService.shared.makePostRequest(page: RequestPath.Registration.registerPhone, params: [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phone)], completion: completionForSegue)
    }
    
    func completionForSegue(for response: Result<Response, ErrorResponse>) {
        switch response {
            case .success:
                performSegue(for: segueCode)
            case .failure(let error):
                displayError(with: error.message ?? AppErrors.unknownError.rawValue) { [self] in
                    indicator.stopAnimating()
                    sendPhoneButton.fadeIn(0.3)
                }
        }
    }
}
