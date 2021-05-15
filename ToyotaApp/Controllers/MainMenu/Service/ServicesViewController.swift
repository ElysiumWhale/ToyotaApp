import UIKit

class ServicesViewController: UIViewController, BackgroundText {
    @IBOutlet private var carTextField: UITextField!
    @IBOutlet private var showroomLabel: UILabel!
    @IBOutlet private var servicesList: UICollectionView!
    
    private let refreshControl = UIRefreshControl()
    private var carForServePicker: UIPickerView = UIPickerView()
    private let cellIdentrifier = CellIdentifiers.ServiceCell
    
    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }
    
    private var cars: [Car] { user.getCars.array }
    private var selectedCar: Car? { user.getCars.chosenCar }
    private var serviceTypes: [ServiceType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carTextField.tintColor = .clear
        refreshControl.attributedTitle = NSAttributedString(string: "Потяните для обновления")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        servicesList.refreshControl = refreshControl
        servicesList.alwaysBounceVertical = true
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
    
    @IBAction private func refresh() {
        serviceTypes.removeAll()
        servicesList.reloadData()
        refreshControl.beginRefreshing()
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getServicesTypes, params: [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: selectedCar!.showroomId)], completion: carDidSelectCompletion)
    }
    
    @IBAction private func carDidSelect(sender: Any?) {
        view.endEditing(true)
        let row = carForServePicker.selectedRow(inComponent: 0)
        if selectedCar!.id != cars[row].id {
            serviceTypes.removeAll()
            servicesList.reloadData()
            refreshControl.beginRefreshing()
            user.update(cars[row])
            carTextField.text = "\(selectedCar?.brand ?? "Brand") \(selectedCar?.model ?? "Model")"
            showroomLabel.text = user.getSelectedShowroom?.showroomName ?? "Showroom"
            DefaultsManager.pushUserInfo(info: Cars(cars))
            NetworkService.shared.makePostRequest(page: RequestPath.Services.getServicesTypes, params: [URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: selectedCar!.showroomId)], completion: carDidSelectCompletion)
        }
    }
    
    private func carDidSelectCompletion(for response: Result<ServicesTypesDidGetResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                DispatchQueue.main.async { [self] in
                    refreshControl.endRefreshing()
                    serviceTypes = data.service_type
                    servicesList.reloadData()
                    if serviceTypes.count < 1 {
                        servicesList.backgroundView = createBackground(labelText: "Для данного автомобиля пока нет доступных сервисов. Не волнуйтесь, они скоро появятся.")
                    } else {
                        servicesList.backgroundView = nil;
                    }
                }
            case .failure(let error):
                switch error.code {
                    case NetworkErrors.lostConnection.rawValue:
                        DispatchQueue.main.async { [self] in
                            refreshControl.endRefreshing()
                            servicesList.backgroundView = createBackground(labelText: "Ошибка сети, проверьте подключение и повторите попытку, потянув вниз")
                        }
                    default:
                        DispatchQueue.main.async { [self] in
                            displayError(with: error.message ?? "Ошибка загрузки доступных сервисов, попробуйте еще раз")
                            refreshControl.endRefreshing()
                            servicesList.backgroundView = createBackground(labelText: "Потяните вниз для загрузки доступных сервисов.")
                        }
                }
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
        DispatchQueue.main.async { [self] in
            view.layoutIfNeeded()
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
}

//MARK: - Configure UI for cars count
extension ServicesViewController {
    private func interfaceIfNoCars() {
        displayError(with: "Увы, на данный момент Вам недоступен полный функционал приложения. Для разблокировки добавьте автомобиль.")
        carTextField.isEnabled = false
        refreshControl.endRefreshing()
        showroomLabel.text = ""
        servicesList.backgroundView = createBackground(labelText: "Добавьте автомобиль для разблокировки функций")
    }
    
    private func interfaceIfOneCar() {
        if servicesList.backgroundView != nil { servicesList.backgroundView = nil }
        carTextField.text = "\(selectedCar?.brand ?? "Brand") \(selectedCar?.model ?? "Model")"
        carTextField.isEnabled = cars.count > 1
        showroomLabel.text = user.getSelectedShowroom?.showroomName ?? "Showroom"
        refreshControl.beginRefreshing()
        NetworkService.shared.makePostRequest(page: RequestPath.Services.getServicesTypes, params: [URLQueryItem(name:  RequestKeys.CarInfo.showroomId, value: selectedCar!.showroomId)], completion: carDidSelectCompletion)
    }
    
    private func interfaceIfManyCars() {
        carForServePicker.reloadAllComponents()
        carForServePicker.selectRow(cars.firstIndex(where: {$0.id == selectedCar?.id }) ?? 0,
                                    inComponent: 0, animated: false)
        carTextField.isEnabled = true
        interfaceIfOneCar()
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
}
