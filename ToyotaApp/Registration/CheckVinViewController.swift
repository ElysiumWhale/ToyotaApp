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
extension CheckVinViewController: SegueWithRequestController {
    var segueCode: String { SegueIdentifiers.CarToEndRegistration }
    
    @IBAction func nextButtonDidPressed(sender: Any?) {
        guard let vin = vinCodeTextField.text else { displayError(nil); return }
        guard vin.count == 17 else { displayError(nil); return }
        indicator.startAnimating()
        checkVinButton.isHidden = true
        indicator.isHidden = false
        NetworkService.shared.makePostRequest(page: PostRequestPath.checkCar, params:
                [URLQueryItem(name: PostRequestKeys.showroomId, value: showroomId!),
                 URLQueryItem(name: PostRequestKeys.vinCode, value: vin),
                 URLQueryItem(name: PostRequestKeys.userId, value: Debug.userId)],
                completion: completionForSegue)
    }
    
    var completionForSegue: (Data?) -> Void {
        { [self] data in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(CarDidCheckResponse.self, from: data)
                    
                    if response.error_code != nil {
                        displayError(response.message)
                    } else {
                        DispatchQueue.main.async {
                            if let userCar = response.car, let vin = vinCodeTextField.text {
                                DefaultsManager.pushUserInfo(info: UserInfo.Cars(array: [userCar.toDomain(with: vin, showroom: showroomId!)]))
                                UserDefaults.standard.set(vin, forKey: DefaultsKeys.vin)
                                performSegue(withIdentifier: segueCode, sender: self)
                            } else { displayError("Сервер прислал неверные данные") }
                        }
                    }
                }
                catch let decodeError as NSError {
                    print("Decoder error: \(decodeError.localizedDescription)")
                    displayError("Сервер прислал неверные данные")
                }
            } else {
                displayError("Ошибка при получении данных")
            }
        }
    }
}
