import UIKit

class TestDriveViewController: UIViewController {
    @IBOutlet private(set) var label: UILabel!
    
    private(set) var serviceType: ServiceType!
    private(set) var selectedCar: Car!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "\(serviceType.service_type_name) \(selectedCar.model)"
    }
}

extension TestDriveViewController: ServicesMapped {
    func configure(with service: ServiceType, car: Car) {
        serviceType = service
        selectedCar = car
    }
}
