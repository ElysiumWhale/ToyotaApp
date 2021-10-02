import UIKit

class AuthViewController: UIViewController {
    @IBOutlet private var phoneNumber: PhoneTextField!
    @IBOutlet private var incorrectLabel: UILabel!
    @IBOutlet private var informationLabel: UILabel!
    @IBOutlet private var sendPhoneButton: KeyboardBindedButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!

    private let segueCode = SegueIdentifiers.numberToCode

    private var type: AuthType = .register

    private lazy var authRequestHandler: RequestHandler<Response> = {
        let handler = RequestHandler<Response>()
        
        handler.onSuccess = { [weak self] _ in
            DispatchQueue.main.async {
                self?.handle(isSuccess: true)
            }
        }
        
        handler.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.handle(isSuccess: false)
                PopUp.display(.error(description: error.message ?? .error(.unknownError)))
            }
        }
        
        return handler
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        incorrectLabel.alpha = 0
        view.hideKeyboardWhenSwipedDown()
        sendPhoneButton.bindToKeyboard()
        
        if case .changeNumber = type {
            informationLabel.text = .common(.enterNewNumber)
        }
    }

    func configure(with authType: AuthType) {
        type = authType
    }

    @IBAction func phoneNumberDidChange(sender: UITextField) {
        incorrectLabel.fadeOut(0.3)
        phoneNumber.toggle(state: .normal)
    }

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
        NetworkService.makeRequest(page: .registration(.registerPhone),
                                   params: [(.personalInfo(.phoneNumber), phone)],
                                   handler: authRequestHandler)
    }

    private func handle(isSuccess: Bool) {
        indicator.stopAnimating()
        sendPhoneButton.fadeIn()
        if isSuccess {
            perform(segue: segueCode)
        }
    }
}

// MARK: - Navigation
extension AuthViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.code {
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
