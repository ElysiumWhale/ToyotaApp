import UIKit

protocol AddingCarDelegate {
    func carDidChecked()
}

class CheckVinViewController: UIViewController {
    
    @IBOutlet private var regNumber: UILabel!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var vinCodeTextField: UITextField!
    @IBOutlet private var checkVinButton: UIButton!
    
    var car: Car?
    var parentDelegate: AddingCarDelegate!
    
    @IBAction func vinValueDidChange(with sender: UITextField) {
        if sender.text?.count == 17 {
            checkVinButton.isEnabled = true
        }
        errorLabel.isHidden = true
        vinCodeTextField.layer.borderWidth = 0
    }
    
    @IBAction func checkVin() {
        guard let vin = vinCodeTextField.text else { displayError(); return }
        NetworkService.shared.makePostRequest(page: PostRequestPath.checkCar, params:
                [URLQueryItem(name: PostRequestKeys.carId, value: car!.id),
                 URLQueryItem(name: PostRequestKeys.vinCode, value: vin),
                 URLQueryItem(name: PostRequestKeys.userId, value: Debug.userId)],
                completion: {_ in })
    }
    
    func displayError() {
        vinCodeTextField.layer.borderColor = UIColor.systemRed.cgColor
        vinCodeTextField.layer.borderWidth = 1
        errorLabel.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        regNumber.text = car!.license_plate
    }
    
//    private var completion: (Data?) -> Void {
//        { [self] data in
//            if let data = data {
//                do {
//
//                }
//                catch let decodeError as NSError {
//                    print("Decoder error: \(decodeError.localizedDescription)")
//                }
//            }
//        }
//    }
}
