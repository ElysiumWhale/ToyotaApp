import UIKit

protocol AddingCarDelegate {
    func carDidChecked()
}

class CheckVinViewController: UIViewController {
    
    @IBOutlet private var regNumber: UILabel!
    @IBOutlet private var modelName: UILabel!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var vinCodeTextField: UITextField!
    @IBOutlet private var checkVinButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    
    let segueCode = SegueIdentifiers.CarToEndRegistration
    var car: DTOCar?
    var parentDelegate: AddingCarDelegate!
    
    @IBAction func vinValueDidChange(with sender: UITextField) {
        errorLabel.isHidden = true
        vinCodeTextField.layer.borderWidth = 0
    }
    
    @IBAction func checkVin() {
        guard let vin = vinCodeTextField.text else { displayError(nil); return }
        guard vin.count == 17 else { displayError(nil); return }
        indicator.startAnimating()
        checkVinButton.isHidden = true
        indicator.isHidden = false
        NetworkService.shared.makePostRequest(page: PostRequestPath.checkCar, params:
                //[URLQueryItem(name: PostRequestKeys.carId, value: car!.id),
                 [URLQueryItem(name: PostRequestKeys.vinCode, value: vin),
                 URLQueryItem(name: PostRequestKeys.userId, value: Debug.userId)],
                completion: completion)
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
        //regNumber.text = car!.licensePlate
        //modelName.text = " \(car!.brandName) \(car!.modelName)"
    }
    
    private var completion: (Data?) -> Void {
        { [self] data in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(CarDidCheckResponse.self, from: data)
                    
                    #warning("to-do response with car")
                    let car = Car(id: "todo", brand: "todo", model: "todo", color: "todo", colorSwatch: "todo", colorDescription: "todo", isMetallic: "todo", plate: "todo", vin: vinCodeTextField.text!)
                    
                    DefaultsManager.pushUserInfo(info: UserInfo.Cars(array: [car]))
                    
                    DispatchQueue.main.async {
                        indicator.stopAnimating()
                        indicator.isHidden = true
                        checkVinButton.isHidden = false
                        if response.error_code != nil {
                            displayError(response.message)
                        } else {
                            UserDefaults.standard.set(vinCodeTextField.text, forKey: DefaultsKeys.vin)
                            performSegue(withIdentifier: segueCode, sender: self)
                        }
                    }
                }
                catch let decodeError as NSError {
                    print("Decoder error: \(decodeError.localizedDescription)")
                    displayError("Сервер прислал неверные данные")
                }
            }
        }
    }
}
