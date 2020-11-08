import UIKit

class CheckVinViewController: UIViewController {
    
    @IBOutlet var regNumber: UILabel!
    @IBOutlet var vinCodeTextField: UITextField!
    
    var car: Car?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        regNumber.text = car!.license_plate
    }
}
