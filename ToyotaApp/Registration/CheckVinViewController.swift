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
    
    var car: Car?
    var parentDelegate: AddingCarDelegate!
    
    @IBAction func vinValueDidChange(with sender: UITextField) {
        errorLabel.isHidden = true
        vinCodeTextField.layer.borderWidth = 0
    }
    
    @IBAction func checkVin() {
        guard let vin = vinCodeTextField.text else { displayError(); return }
        guard vin.count == 17 else { displayError(); return }
        indicator.startAnimating()
        checkVinButton.isHidden = true
        indicator.isHidden = false
        NetworkService.shared.makePostRequest(page: PostRequestPath.checkCar, params:
                [URLQueryItem(name: PostRequestKeys.carId, value: car!.id),
                 URLQueryItem(name: PostRequestKeys.vinCode, value: vin),
                 URLQueryItem(name: PostRequestKeys.userId, value: Debug.userId)],
                completion: completion)
    }
    
    func displayError() {
        DispatchQueue.main.async { [self] in
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
        regNumber.text = car!.licensePlate
        modelName.text = " \(car!.brandName) \(car!.modelName)"
    }
    
    private var completion: (Data?) -> Void {
        { [self] data in
            if let data = data {
                do {
                    _ = try JSONDecoder().decode(CarDidCheckResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        indicator.stopAnimating()
                        indicator.isHidden = true
                        checkVinButton.isHidden = false
                        dismiss(animated: true, completion: parentDelegate.carDidChecked)
                    }
                }
                catch let decodeError as NSError {
                    print("Decoder error: \(decodeError.localizedDescription)")
                    displayError()
                }
            }
        }
    }
}
