import UIKit

class CheckVinViewController: UIViewController {
    @IBOutlet private var regNumber: UILabel!
    @IBOutlet private var modelName: UILabel!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var vinCodeTextField: UITextField!
    @IBOutlet private var checkVinButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    
    var showroomId: String?
    
    @IBAction func vinValueDidChange(with sender: UITextField) {
        errorLabel.isHidden = true
        vinCodeTextField.layer.borderWidth = 0
    }
    
    func displayError(_ message: String?) {
        DispatchQueue.main.async { [self] in
            if let mes = message {
                PopUpPreset.display(with: "Ошибка", description: mes, buttonText: "Ок")
            }
            vinCodeTextField.layer.borderColor = UIColor.systemRed.cgColor
            vinCodeTextField.layer.borderWidth = 1
            errorLabel.isHidden = false
            if checkVinButton.isHidden == true {
                indicator.stopAnimating()
                indicator.isHidden = true
                checkVinButton.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: - SegueWithRequestController
extension CheckVinViewController: SegueWithRequestController {
    var segueCode: String { SegueIdentifiers.CarToEndRegistration }
    
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard let vin = vinCodeTextField.text else { displayError(nil); return }
        guard vin.count == 17 else { displayError(nil); return }
        makeRequest(skip: "0", vin: vin)
    }
    
    @IBAction func skipButtonDidPressed(sender: Any?) { makeRequest(skip: "1", vin: "") }
    
    private func makeRequest(skip: String, vin: String) {
        indicator.startAnimating()
        checkVinButton.isHidden = true
        indicator.isHidden = false
        
        let userId = UserDefaults.standard.string(forKey: DefaultsKeys.userId)
        
        NetworkService.shared.makePostRequest(page: PostRequestPath.checkCar, params:
                [URLQueryItem(name: PostRequestKeys.skipStep, value: skip),
                 URLQueryItem(name: PostRequestKeys.showroomId, value: showroomId!),
                 URLQueryItem(name: PostRequestKeys.vinCode, value: vin),
                 URLQueryItem(name: PostRequestKeys.userId, value: userId)],
                completion: completionForSegue)
    }
    
    var completionForSegue: (CarDidCheckResponse?) -> Void {
        { [self] response in
            if let response = response {
               if response.error_code != nil { displayError(response.message) }
               else { DispatchQueue.main.async {
                   if let userCar = response.car, let vin = vinCodeTextField.text {
                       let car = userCar.toDomain(with: vin, showroom: showroomId!)
                       DefaultsManager.pushUserInfo(info:
                           UserInfo.Cars(chosenCar: car, array: [car])
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
