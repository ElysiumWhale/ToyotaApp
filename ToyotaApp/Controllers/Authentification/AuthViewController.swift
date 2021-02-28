import UIKit
import PhoneNumberKit

class AuthViewController: UIViewController {
    
    @IBOutlet var phoneNumber: PhoneNumberTextField!
    @IBOutlet var incorrectLabel: UILabel!
    @IBOutlet var sendPhoneButton: UIButton!
    @IBOutlet var indicator: UIActivityIndicatorView!
       
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
    }
    
    //MARK: - TEST METHOD
    func configureTextField() {
        phoneNumber.layer.cornerRadius = 10
        phoneNumber.withPrefix = true
        phoneNumber.withFlag = true
        phoneNumber.maxDigits = 10
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
                let destinationVC = segue.destination as? SmsCodeViewController
                destinationVC?.phoneNumber = phoneNumber?.text
            default: return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        indicator.stopAnimating()
        indicator.isHidden = true
        sendPhoneButton.isHidden = false
    }
}

//MAK: - SegueWithRequestController
extension AuthViewController: SegueWithRequestController {
    typealias Response = FailureResponse
    
    var segueCode: String { SegueIdentifiers.NumberToCode }
    
    @IBAction func nextButtonDidPressed(sender: Any?) {
        if !(phoneNumber.isValidNumber) {
            phoneNumber.layer.borderColor = UIColor.systemRed.cgColor
            phoneNumber.layer.borderWidth = 1.0
            incorrectLabel.isHidden = false
        } else {
            indicator.startAnimating()
            sendPhoneButton.isHidden = true
            indicator.isHidden = false
            view.endEditing(true)
            DefaultsManager.pushUserInfo(info: Phone(phoneNumber.text!))
            NetworkService.shared.makeSimpleRequest(page: RequestPath.Registration.registerPhone, params: [URLQueryItem(name: RequestKeys.PersonalInfo.phoneNumber, value: phoneNumber.text)])
            performSegue(withIdentifier: segueCode, sender: self)
        }
    }
}
