import UIKit

class ServicesViewController: PickerController {
    @IBOutlet private(set) var carTextField: UITextField!
    @IBOutlet private(set) var loadingIndicator: UIActivityIndicatorView!
    
    private var userInfo: UserInfo?
    
    let techOverviewSegue = ""
    let feedbackSegue = ""
    let testDriveSegue = ""
    let emergencySegue = ""
    let serviceSegue = ""
    
    private var carForServePicker: UIPickerView = UIPickerView()
    private var cars: UserInfo.Cars { userInfo!.cars }
    private var selectedCar: Car?
    
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
        
        NetworkService.shared.makePostRequest(page: PostRequestPath.getServicesTypes, params: [URLQueryItem(name: PostRequestKeys.showroomId, value: selectedCar!.showroomId)], completion: completion)
    }
    
    func completion(data: Data?) {
        //buildUI
    }
    
    @objc private func carDidSelect(sender: Any?) {
        NetworkService.shared.makePostRequest(page: PostRequestPath.getServicesTypes, params: [URLQueryItem(name: PostRequestKeys.showroomId, value: selectedCar!.showroomId)], completion: completion)
        //buildUI
    }
}

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
