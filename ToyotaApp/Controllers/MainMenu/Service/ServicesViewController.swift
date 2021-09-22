import UIKit

class ServicesViewController: UIViewController, BackgroundText {
    @IBOutlet private var carTextField: NoCopyPasteTexField!
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
        servicesList.alwaysBounceVertical = true
        hideKeyboardWhenTappedAround()
        configurePicker(carForServePicker, with: #selector(carDidSelect), for: carTextField, delegate: self)
        
        switch cars.count {
            case 0: interfaceIfNoCars()
            case 1: interfaceIfOneCar()
            default: interfaceIfManyCars()
        }
    }

    @IBAction private func refresh() {
        serviceTypes.removeAll()
        servicesList.reloadData()
        refreshControl.beginRefreshing()
        NetworkService.makePostRequest(page: .services(.getServicesTypes),
                                       params: [URLQueryItem(.carInfo(.showroomId),
                                                             selectedCar!.showroomId)],
                                       completion: carDidSelectCompletion)
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
            KeychainManager.set(Cars(cars))
            NetworkService.makePostRequest(page: .services(.getServicesTypes),
                                           params: [URLQueryItem(.carInfo(.showroomId),
                                                                 selectedCar!.showroomId)],
                                           completion: carDidSelectCompletion)
        }
    }

    private func carDidSelectCompletion(for response: Result<ServicesTypesDidGetResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                DispatchQueue.main.async { [weak self] in
                    guard let vc = self else { return }
                    vc.serviceTypes = data.serviceType
                    vc.servicesList.reloadData()
                    vc.endRefreshing()
                    vc.servicesList.backgroundView = vc.serviceTypes.count < 1 ? vc.createBackground(labelText: .noServices) : nil
                }
            case .failure(let error):
                var labelMessage = ""
                switch error.errorCode {
                    case .lostConnection:
                        labelMessage = .networkError + " и " + .retryRefresh
                    default:
                        labelMessage = .servicesError + ", " + .retryRefresh
                }
                DispatchQueue.main.async { [weak self] in
                    self?.endRefreshing()
                    self?.servicesList.backgroundView = self?.createBackground(labelText: labelMessage)
                }
        }
    }

    private func endRefreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5,
                                      execute: { [weak self] in self?.refreshControl.endRefreshing() })
    }
}

// MARK: - WithUserInfo
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
                case 0: interfaceIfNoCars()
                case 1: interfaceIfOneCar()
                default: interfaceIfManyCars()
            }
        }
    }
}

// MARK: - Configure UI for cars count
extension ServicesViewController {
    private func interfaceIfNoCars() {
        PopUp.display(.warning(description: .blockFunctionsAlert))
        carTextField.isEnabled = false
        refreshControl.endRefreshing()
        showroomLabel.text = ""
        servicesList.backgroundView = createBackground(labelText: .addAutoToUnlock)
    }

    private func interfaceIfOneCar() {
        refreshControl.attributedTitle = NSAttributedString(string: .pullToRefresh)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        servicesList.refreshControl = refreshControl
         
        if servicesList.backgroundView != nil { servicesList.backgroundView = nil }
        carTextField.text = "\(selectedCar?.brand ?? "Brand") \(selectedCar?.model ?? "Model")"
        carTextField.isEnabled = cars.count > 1
        showroomLabel.text = user.getSelectedShowroom?.showroomName ?? "Showroom"
        refreshControl.beginRefreshing()
        NetworkService.makePostRequest(page: .services(.getServicesTypes),
                                       params: [URLQueryItem(.carInfo(.showroomId),
                                                             selectedCar!.showroomId)],
                                       completion: carDidSelectCompletion)
    }

    private func interfaceIfManyCars() {
        carForServePicker.reloadAllComponents()
        carForServePicker.selectRow(cars.firstIndex(where: {$0.id == selectedCar?.id }) ?? 0,
                                    inComponent: 0, animated: false)
        interfaceIfOneCar()
    }
}

// MARK: - UIPickerViewDataSource
extension ServicesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        cars.count
    }
}

// MARK: - UIPickerViewDelegate
extension ServicesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        cars[row].model
    }
}

// MARK: - UICollectionViewDataSource
extension ServicesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        serviceTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentrifier, for: indexPath) as? ServiceCollectionViewCell
        let serviceType = serviceTypes[indexPath.row]
        cell?.configure(name: serviceType.serviceTypeName, type: ControllerServiceType(rawValue: serviceType.controlTypeId) ?? .notDefined)
        return cell!
    }
}

// MARK: - UICollectionViewDelegate
extension ServicesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) as? ServiceCollectionViewCell != nil,
           let serviceType = ControllerServiceType(rawValue: serviceTypes[indexPath.row].controlTypeId),
           let controller = ServiceModuleBuilder.buildController(serviceType: serviceTypes[indexPath.row], for: serviceType, user: user) as? UIViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0.05 * Double(indexPath.row),
                       animations: { cell.alpha = 1 })
    }
}
