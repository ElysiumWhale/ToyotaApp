import UIKit

class ServicesViewController: UIViewController, BackgroundText {
    @IBOutlet private var carTextField: UITextField!
    @IBOutlet private var showroomLabel: UILabel!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private var servicesList: UICollectionView!
    
    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }
    
    private var carForServePicker: UIPickerView = UIPickerView()
    private var cars: [Car] { user.getCars.array }
    private var selectedCar: Car? { user.getCars.chosenCar }
    
    private var serviceTypes: [ServiceType] = [ServiceType]()
    
    private let cellIdentrifier = CellIdentifiers.ServiceCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carTextField.tintColor = .clear
        hideKeyboardWhenTappedAround()
        configurePicker(carForServePicker, with: #selector(carDidSelect), for: carTextField, delegate: self)
        
        switch cars.count {
            case 0:
                interfaceIfNoCars()
            case 1:
                interfaceIfOneCar()
            default:
                interfaceIfManyCars()
        }
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
        if selectedCar!.id != cars[row].id {
            serviceTypes.removeAll()
            servicesList.reloadData()
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            user.update(cars[row])
            carTextField.text = "\(selectedCar?.brand ?? "Brand") \(selectedCar?.model ?? "Model")"
            showroomLabel.text = user.getSelectedShowroom?.showroomName ?? "Showroom"
            DefaultsManager.pushUserInfo(info: Cars(cars))
            NetworkService.shared.makePostRequest(page: RequestPath.Services.getServicesTypes, params: [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: selectedCar!.showroomId)], completion: completion)
        }
    }
    
    private func interfaceIfOneCar() {
        DispatchQueue.main.async { [self] in
            if servicesList.backgroundView != nil { servicesList.backgroundView = nil }
            carTextField.text = "\(selectedCar?.brand ?? "Brand") \(selectedCar?.model ?? "Model")"
            carTextField.isEnabled = cars.count > 1
            showroomLabel.text = user.getSelectedShowroom?.showroomName ?? "Showroom"
            NetworkService.shared.makePostRequest(page: RequestPath.Services.getServicesTypes, params: [URLQueryItem(name:  RequestKeys.CarInfo.showroomId, value: selectedCar!.showroomId)], completion: completion)
        }
    }
    
    private func interfaceIfNoCars() {
        DispatchQueue.main.async { [self] in
            displayError(whith: "Увы, на данный момент Вам недоступен полный функционал приложения. Для разблокировки добавьте  автомобиль.")
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            showroomLabel.text = ""
            servicesList.backgroundView = createBackground(with: "Добавьте автомобиль для разблокировки функций")
        }
    }
    
    private func interfaceIfManyCars() {
        DispatchQueue.main.async { [self] in
            carForServePicker.reloadAllComponents()
            carForServePicker.selectRow(cars.firstIndex(where: {$0.id == selectedCar?.id }) ?? 0,
                                        inComponent: 0, animated: false)
            interfaceIfOneCar()
        }
    }
}

//MARK: - WithUserInfo
extension ServicesViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
    
    func subscribe(on proxy: UserProxy) {
        proxy.getNotificator.add(observer: self)
    }
    
    func unsubscribe(from proxy: UserProxy) {
        proxy.getNotificator.remove(obsever: self)
    }
    
    func userDidUpdate() {
        switch cars.count {
            case 0:
                interfaceIfNoCars()
            case 1:
                interfaceIfOneCar()
            default:
                interfaceIfManyCars()
        }
    }
}

//MARK: - UIPickerViewDataSource
extension ServicesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        cars.count
    }
}

//MARK: - UIPickerViewDelegate
extension ServicesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        cars[row].model
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
