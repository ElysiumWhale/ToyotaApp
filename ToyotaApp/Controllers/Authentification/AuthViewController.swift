import UIKit
import PhoneNumberKit

enum AuthType {
    case first
    case changeNumber
}

class AuthViewController: UIViewController {
    @IBOutlet private var phoneNumber: PhoneNumberTextField!
    @IBOutlet private var incorrectLabel: UILabel!
    @IBOutlet private var informationLabel: UILabel!
    @IBOutlet private var sendPhoneButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    
    private var type: AuthType = .first
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
    }
    
    func configure(with authType: AuthType) {
        type = authType
    }
    
    func configureTextField() {
        phoneNumber.layer.cornerRadius = 10
        phoneNumber.withPrefix = true
        phoneNumber.withFlag = true
        phoneNumber.maxDigits = 10
        if type == .changeNumber {
            informationLabel.text = "Введите новый номер:"
        }
    }
    
    @IBAction func phoneNumberDidChange(sender: UITextField) {
       incorrectLabel!.isHidden = true
       phoneNumber?.layer.borderWidth = 0
    }
}

//MARK: - Navigation
extension AuthViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueCode:
                let destinationVC = segue.destination as! SmsCodeViewController
                destinationVC.configure(with: type, and: phoneNumber.text!)
            default: return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        indicator.stopAnimating()
        indicator.isHidden = true
        sendPhoneButton.isHidden = false
    }
}

//MARK: - SegueWiRhRequestController
extension AuthViewController: SegueWithRequestController {
    typealias TResponse = Response
    
    var segueCode: String { SegueIdentifiers.NumberToCode }
    
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard phoneNumber.isValidNumber else {
            phoneNumber.layer.borderColor = UIColor.systemRed.cgColor
            phoneNumber.layer.borderWidth = 1.0
            incorrectLabel.isHidden = false
            return
        }
        indicator.startAnimating()
        sendPhoneButton.isHidden = true
        indicator.isHidden = false
        view.endEditing(true)
        if type == .first {
            DefaultsManager.pushUserInfo(info: Phone(phoneNumber.text!))
        }
        NetworkService.shared.makePostRequest(page: RequestPath.Registration.registerPhone, params: [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber.text)], completion: completion)
    }
    
    func completion(response: Response?) {
        if response != nil {
            DispatchQueue.main.async { [self] in
                performSegue(withIdentifier: segueCode, sender: self)
            }
        }
    }
}
