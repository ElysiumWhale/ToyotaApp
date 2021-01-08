import UIKit

class ServicesViewController: PickerController {
    @IBOutlet private(set) var carTextField: UITextField!
    @IBOutlet private(set) var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private(set) var buttonsStackView: UIStackView!
    
    private var userInfo: UserInfo?
    
    let techOverviewSegue = ""
    let feedbackSegue = ""
    let testDriveSegue = ""
    let emergencySegue = ""
    let serviceSegue = ""
    
    private var carForServePicker: UIPickerView = UIPickerView()
    private var cars: UserInfo.Cars { userInfo!.cars }
    private var selectedCar: Car?
    
    private var serviceTypes: [ServiceType] = [ServiceType]()
    private var buttons: [UIButton] = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if cars.array.count == 1 {
            carTextField.text = "\(cars.array.first!.brand) \(cars.array.first!.model)"
            carTextField.isEnabled = false
        } else {
            configurePicker(view: carForServePicker, with: #selector(carDidSelect), for: carTextField, delegate: self)
            #warning("to-do: check if car chosen in memory")
            carForServePicker.selectRow(0, inComponent: 0, animated: false)
            carTextField.text = "\(cars.array.first!.brand) \(cars.array.first!.model)"
            selectedCar = cars.array.first
        }
        
        //buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NetworkService.shared.makePostRequest(page: PostRequestPath.getServicesTypes, params: [URLQueryItem(name: PostRequestKeys.showroomId, value: selectedCar!.showroomId)], completion: completion)
    }
    
    func completion(response: ServicesTypesDidGetResponse?) {
        DispatchQueue.main.async { [self] in
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            carTextField.isHidden = false
            if let resp = response, let types = resp.service_type {
                //serviceTypes = types
                serviceTypes = [ServiceType(id: "1", service_type_name: "Тест драйв"),
                                ServiceType(id: "2", service_type_name: "Услуги сервиса"),
                                ServiceType(id: "3", service_type_name: "Обслуживание")]
                if !buttonsStackView.subviews.isEmpty {
                    buttonsStackView.removeAllArrangedSubviews()
                }
                for type in serviceTypes {
                    #warning("to-do: xib reusable view implementation")
                    let button = ConstructorButton<ServiceType>()
                    button.parameter = type
                    button.addTarget(self, action: #selector(action), for: .touchUpInside)
                    button.backgroundColor = .init(red: 223.0/255.0, green: 66.0/255.0, blue: 76.0/255.0, alpha: 1.0)
                    button.setTitle(type.service_type_name, for: .normal)
                    button.titleLabel!.font = UIFont(name: "ToyotaType-Book", size: 21)
                    button.layer.cornerRadius = 10
                    button.layer.masksToBounds = true
                    buttons.append(button)
                    buttonsStackView.addArrangedSubview(button)
                }
            }
        }
    }
    
    @objc func action(sender: UIButton) {
        DispatchQueue.main.async { [self] in
            let storyBoard = UIStoryboard(name: AppStoryboards.main, bundle: nil)
            let vc = storyBoard.instantiateViewController(identifier: AppViewControllers.constructor) as! ConstructorViewController
            vc.configure(with: selectedCar!.showroomId, and: (sender as! ConstructorButton<ServiceType>).parameter.id)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func carDidSelect(sender: Any?) {
        buttons.removeAll()
        serviceTypes.removeAll()
        view.endEditing(true)
        NetworkService.shared.makePostRequest(page: PostRequestPath.getServicesTypes, params: [URLQueryItem(name: PostRequestKeys.showroomId, value: selectedCar!.showroomId)], completion: completion)
    }
}

//MARK: - WithUserInfo
extension ServicesViewController: WithUserInfo {
    func setUser(info: UserInfo) {
        userInfo = info
    }
}

//MARK: - UIPickerViewDataSource
extension ServicesViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
            case carForServePicker: return cars.array.count
            default: return 1
        }
    }
}

//MARK: - UIPickerViewDelegate
extension ServicesViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
            case carForServePicker: return cars.array[row].model
            default: return "Object is missing"
        }
    }
}
