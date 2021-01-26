import UIKit

class TestDriveViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
}

extension TestDriveViewController: ServiceWithConfigure {
    func configure(with service: ServiceType, car: Car) {
        
    }
}
