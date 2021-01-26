import UIKit

class TestDriveViewController: UIViewController {
    @IBOutlet private(set) var datePicker: UIDatePicker!
    @IBOutlet private(set) var carTextField: UITextField!
    @IBOutlet private(set) var dealerTextField: UITextField!
    @IBOutlet private(set) var indicator: UIActivityIndicatorView!
    
    private(set) var serviceType: ServiceType!
    private(set) var selectedDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = serviceType.service_type_name
        datePicker.minimumDate = Date()
        indicator.stopAnimating()
        indicator.isHidden = true
    }
}

extension TestDriveViewController: ServicesMapped {
    func configure(with service: ServiceType, car: Car) {
        serviceType = service
    }
}
