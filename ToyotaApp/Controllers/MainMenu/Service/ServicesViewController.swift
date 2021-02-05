import UIKit

class ServicesViewController: PickerController {
    @IBOutlet private(set) var carTextField: UITextField!
    @IBOutlet private(set) var showroomLabel: UILabel!
    @IBOutlet private(set) var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private(set) var servicesList: UICollectionView!
    
    private var userInfo: UserInfo!
    
    private var carForServePicker: UIPickerView = UIPickerView()
    private var cars: UserInfo.Cars { userInfo!.cars }
    private var selectedCar: Car?
    
    private var serviceTypes: [ServiceType] = [ServiceType]()
    
    private let cellIdentrifier = CellIdentifiers.ServiceCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carTextField.tintColor = .clear
        
        guard !cars.array.isEmpty else {
            displayError(whith: "Увы, на данный момень Вам недоступен полный функционал приложения. Для разблокировки добавьте автомобиль.")
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            showroomLabel.text = ""
            return
        }
        
        if let car = userInfo.cars.chosenCar {
            selectedCar = car
        } else {
            selectedCar = cars.array.first
            DefaultsManager.pushAdditionalInfo(info: selectedCar, for: DefaultsKeys.chosenCar)
        }
        
        if cars.array.count == 1 {
            carTextField.text = "\(selectedCar!.brand) \(selectedCar!.model)"
            carTextField.isEnabled = false
        } else {
            configurePicker(carForServePicker, with: #selector(carDidSelect), for: carTextField, delegate: self)
            carTextField.text = "\(selectedCar!.brand) \(selectedCar!.model)"
            carForServePicker.selectRow(cars.array.firstIndex(where: {$0.id == selectedCar?.id }) ?? 0, inComponent: 0, animated: false)
            carTextField.isEnabled = true
        }
        
        showroomLabel.text = userInfo.showrooms.array.first(where: {$0.id == selectedCar!.showroomId})?.showroomName ?? "Empty"
        
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getServicesTypes, params: [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: selectedCar!.showroomId)], completion: completion)
    }
    
    func completion(response: ServicesTypesDidGetResponse?) {
        DispatchQueue.main.async { [self] in
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            carTextField.isHidden = false
            if let resp = response, let types = resp.service_type {
                serviceTypes = types
                servicesList.reloadData()
            }
        }
    }
    
    @objc private func carDidSelect(sender: Any?) {
        view.endEditing(true)
        let row = carForServePicker.selectedRow(inComponent: 0)
        if selectedCar!.id != cars.array[row].id {
            serviceTypes.removeAll()
            servicesList.reloadData()
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            selectedCar = cars.array[row]
            carTextField.text = "\(selectedCar!.brand) \(selectedCar!.model)"
            showroomLabel.text = userInfo.showrooms.array.first(where: {$0.id == selectedCar!.showroomId})!.showroomName
            DefaultsManager.pushAdditionalInfo(info: selectedCar, for: DefaultsKeys.chosenCar)
            NetworkService.shared.makePostRequest(page: RequestPath.Services.getServicesTypes, params: [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: selectedCar!.showroomId)], completion: completion)
        }
    }
}

//MARK: - WithUserInfo
extension ServicesViewController: WithUserInfo {
    func setUser(info: UserInfo) {
        userInfo = info
    }
}

//MARK: - UIPickerViewDataSource
extension ServicesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        cars.array.count
    }
}

//MARK: - UIPickerViewDelegate
extension ServicesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        cars.array[row].model
    }
}

//MARK: - UICollectionViewDataSource
extension ServicesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        serviceTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentrifier, for: indexPath) as! ServiceCollectionViewCell
        let serviceType = serviceTypes[indexPath.row]
        cell.configure(with: serviceType.service_type_name, type: ServicesControllers(rawValue: serviceType.id)!)
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension ServicesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ServiceCollectionViewCell {
            guard let type = AppViewControllers.ServicesMap.map[cell.serviceType] else { return }
            guard let vc = type.init(nibName: String(describing: type), bundle: Bundle.main) as? ServicesMapped else { return }
            vc.configure(with: serviceTypes[indexPath.row], car: selectedCar!)
            navigationController?.pushViewController(vc as! UIViewController, animated: true)
        }
    }
}
