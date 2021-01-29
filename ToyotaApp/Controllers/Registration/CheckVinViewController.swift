import UIKit

fileprivate enum SkipCheckVin: String {
    case yes = "1"
    case no = "0"
}

class CheckVinViewController: UIViewController, DisplayError {
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var vinCodeTextField: UITextField!
    @IBOutlet private var checkVinButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    
    var showroomId: String?
    
    @IBAction func vinValueDidChange(with sender: UITextField) {
        errorLabel.isHidden = true
        vinCodeTextField.layer.borderWidth = 0
    }
    
    func displayError(_ message: String? = nil) {
        DispatchQueue.main.async { [self] in
            if let mes = message {
                PopUp.displayMessage(with: "Ошибка", description: mes, buttonText: "Ок")
            }
            vinCodeTextField.layer.borderColor = UIColor.systemRed.cgColor
            vinCodeTextField.layer.borderWidth = 1
            errorLabel.isHidden = false
            if checkVinButton.isHidden {
                indicator.stopAnimating()
                indicator.isHidden = true
                checkVinButton.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
}

//MARK: - SegueWithRequestController
extension CheckVinViewController: SegueWithRequestController {
    var segueCode: String { SegueIdentifiers.CarToEndRegistration }
    
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard let vin = vinCodeTextField.text else { displayError(); return }
        guard vin.count == 17 else { displayError(); return }
        makeRequest(skip: .no, vin: vin)
    }
    
    @IBAction func skipButtonDidPressed(sender: Any?) { makeRequest(skip: .yes) }
    
    private func makeRequest(skip: SkipCheckVin, vin: String? = "") {
        indicator.startAnimating()
        checkVinButton.isHidden = true
        indicator.isHidden = false
        
        let userId = UserDefaults.standard.string(forKey: DefaultsKeys.userId)
        NetworkService.shared.makePostRequest(page: RequestPath.Registration.checkVin, params:
                    [URLQueryItem(name: RequestKeys.CarInfo.skipStep, value: skip.rawValue),
                     URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroomId!),
                     URLQueryItem(name: RequestKeys.CarInfo.vinCode, value: vin),
                     URLQueryItem(name: RequestKeys.Auth.userId, value: userId)],
                    completion: completionForSegue)
    }
    
    var completionForSegue: (CarDidCheckResponse?) -> Void {
        { [self] response in
            if let response = response {
               if let _ = response.error_code { displayError(response.message) }
               else { DispatchQueue.main.async {
                   if let userCar = response.car, let vin = vinCodeTextField.text {
                       let car = userCar.toDomain(with: vin, showroom: showroomId!)
                       DefaultsManager.pushUserInfo(info:
                            UserInfo.Cars([car], chosen: car)
                       )
                       UserDefaults.standard.set(vin, forKey: DefaultsKeys.vin)
                       performSegue(withIdentifier: segueCode, sender: self)
                   } else {
                       performSegue(withIdentifier: segueCode, sender: self)
                   }
               } }
            } else { displayError("Ошибка при получении данных") }
        }
    }
}
