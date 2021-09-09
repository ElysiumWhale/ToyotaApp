import UIKit

class AuthViewController: UIViewController {
    @IBOutlet private var phoneNumber: PhoneTextField!
    @IBOutlet private var incorrectLabel: UILabel!
    @IBOutlet private var informationLabel: UILabel!
    @IBOutlet private var sendPhoneButton: KeyboardBindedButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!

    private var type: AuthType = .register

    override func viewDidLoad() {
        super.viewDidLoad()
        incorrectLabel.alpha = 0
        configureTextField()
        view.hideKeyboardWhenSwipedDown()
        sendPhoneButton.bindToKeyboard()
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

// MARK: - Navigation
extension AuthViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                let destinationVC = segue.destination as? SmsCodeViewController
                destinationVC?.configure(with: type, and: phoneNumber.phone!)
                indicator.stopAnimating()
            default: return
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        sendPhoneButton.fadeIn()
    }
}

// MARK: - SegueWiRhRequestController
extension AuthViewController: SegueWithRequestController {
    typealias TResponse = Response

    var segueCode: String { SegueIdentifiers.NumberToCode }

    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard let phone = phoneNumber.validPhone else {
            phoneNumber.toggleErrorState(hasError: true)
            incorrectLabel.fadeIn(0.3)
            return
        }
        
        sendPhoneButton.fadeOut()
        indicator.startAnimating()
        view.endEditing(true)
        if case .register = type {
            KeychainManager.set(Phone(phone))
        }
        NetworkService.shared.makePostRequest(page: .regisrtation(.registerPhone),
                                              params: [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber,
                                                                    value: phone)],
                                              completion: completionForSegue)
    }

    func completionForSegue(for response: Result<Response, ErrorResponse>) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self else { return }
            view.indicator.stopAnimating()
            view.sendPhoneButton.fadeIn()
            switch response {
                case .success:
                    view.performSegue(withIdentifier: view.segueCode, sender: view)
                case .failure(let error):
                    PopUp.display(.error(description: error.message ?? AppErrors.unknownError.rawValue))
            }
        }
    }
}
