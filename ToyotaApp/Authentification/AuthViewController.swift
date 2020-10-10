import UIKit
import PhoneNumberKit

class AuthViewController: UIViewController {
    
    @IBOutlet var phoneNumber: PhoneNumberTextField?
    @IBOutlet var incorrectLabel: UILabel?
    @IBOutlet var sendPhoneButton: UIButton?
    @IBOutlet var indicator: UIActivityIndicatorView?
    
    let segueNumberToCode: String = "NumberToCodeSegue"
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumber?.layer.cornerRadius = 15
        self.phoneNumber?.withPrefix = true
        self.phoneNumber?.withFlag = true
        self.phoneNumber?.maxDigits = 10
    }
    
    @IBAction func phoneNumberDidChange(sender: UITextField) {
            incorrectLabel!.isHidden = true
            phoneNumber?.layer.borderWidth = 0
    }
    
//MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case segueNumberToCode:
                let destinationVC = segue.destination as? SmsCodeViewController
                destinationVC?.phoneNumber = phoneNumber?.text
            default:
                return
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
            case segueNumberToCode:
                if !(phoneNumber!.isValidNumber) {
                    phoneNumber?.layer.borderColor = UIColor.systemRed.cgColor
                    phoneNumber?.layer.borderWidth = 1.0
                    incorrectLabel!.isHidden = false
                    return false
                } else {
                    indicator!.startAnimating()
                    sendPhoneButton!.isHidden = true
                    indicator!.isHidden = false
                    //sendPhone
                    return true
                }
            default: return true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        indicator?.stopAnimating()
        indicator?.isHidden = true
        sendPhoneButton?.isHidden = false
    }
}
