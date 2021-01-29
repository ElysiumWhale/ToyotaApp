import UIKit

class ServiceMaintenanceViewController: PickerController {
    @IBOutlet private(set) var servicesTextField: UITextField!
    @IBOutlet private(set) var datePicker: UIDatePicker!
    @IBOutlet private(set) var indicator: UIActivityIndicatorView!
    @IBOutlet private(set) var createRequestButton: UIButton!
    
    private var servicePicker: UIPickerView = UIPickerView()
    
    private var serviceType: ServiceType!
    private var chosenCar: Car!
    private var services: [Service] = [Service]()
    private var selectedService: Service?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = serviceType.service_type_name
        datePicker.minimumDate = Date()
        
        configurePicker(view: servicePicker, with: #selector(serviceDidSelect), for: servicesTextField, delegate: self)
        
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getServices, params: [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: chosenCar.showroomId),
             URLQueryItem(name: RequestKeys.Services.serviceTypeId, value: serviceType.id)],
            completion: completion)
    }
    
    func completion(response: ServicesDidGetResponse?) {
        if let array = response?.services {
            services = array
        }
    }
    
    @objc func serviceDidSelect(sender: Any?) {
        let row = servicePicker.selectedRow(inComponent: 0)
        selectedService = services[row]
        servicesTextField?.text = services[row].service_name
        view.endEditing(true)
        createRequestButton.isHidden = false
    }
}

//MARK: - ServicesMapped
extension ServiceMaintenanceViewController: ServicesMapped {
    func configure(with service: ServiceType, car: Car) {
        serviceType = service
        chosenCar = car
    }
}

//MARK: -
extension ServiceMaintenanceViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return services.count
    }
}

//MARK: -
extension ServiceMaintenanceViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return services[row].service_name
    }
}
