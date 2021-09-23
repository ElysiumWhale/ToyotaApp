import UIKit

class ServicesViewController: RefreshableController, BackgroundText {
    @IBOutlet private var carTextField: NoCopyPasteTexField!
    @IBOutlet private var showroomLabel: UILabel!
    @IBOutlet private(set) var refreshableView: UICollectionView!

    private(set) var refreshControl = UIRefreshControl()
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
        refreshableView.alwaysBounceVertical = true
        hideKeyboardWhenTappedAround()
        configurePicker(carForServePicker, with: #selector(carDidSelect), for: carTextField, delegate: self)
        
        switch cars.count {
            case 0: layoutIfNoCars()
            case 1: layoutIfOneCar()
            default: layoutIfManyCars()
        }
    }

    func startRefreshing() {
        serviceTypes.removeAll()
        refreshableView.reloadData()
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
            refreshableView.reloadData()
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
                    vc.refreshableView.reloadData()
                    vc.endRefreshing()
                    vc.refreshableView.backgroundView = vc.serviceTypes.count < 1 ? vc.createBackground(labelText: .background(.noServices)) : nil
                }
            case .failure(let error):
                var labelMessage = ""
                switch error.errorCode {
                    case .lostConnection:
                        labelMessage = .error(.networkError) + " и "
                    default:
                        labelMessage = .error(.servicesError) + ", "
                }
                DispatchQueue.main.async { [weak self] in
                    self?.endRefreshing()
                    self?.refreshableView.backgroundView = self?.createBackground(labelText: labelMessage + .common(.retryRefresh))
                }
        }
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
            view.setNeedsLayout()
            switch cars.count {
                case 1: layoutIfOneCar()
                case 2...: layoutIfManyCars()
                default: layoutIfNoCars()
            }
        }
    }
}

// MARK: - Configure UI for cars count
extension ServicesViewController {
    private func layoutIfNoCars() {
        PopUp.display(.warning(description: .error(.blockFunctionsAlert)))
        carTextField.isEnabled = false
        refreshControl.endRefreshing()
        showroomLabel.text = ""
        refreshableView.backgroundView = createBackground(labelText: .background(.addAutoToUnlock))
    }

    private func layoutIfOneCar() {
        configureRefresh()
        if refreshableView.backgroundView != nil { refreshableView.backgroundView = nil }
        carTextField.text = "\(selectedCar?.brand ?? "Brand") \(selectedCar?.model ?? "Model")"
        carTextField.isEnabled = cars.count > 1
        showroomLabel.text = user.getSelectedShowroom?.showroomName ?? "Showroom"
        refreshControl.beginRefreshing()
        NetworkService.makePostRequest(page: .services(.getServicesTypes),
                                       params: [URLQueryItem(.carInfo(.showroomId),
                                                             selectedCar!.showroomId)],
                                       completion: carDidSelectCompletion)
    }

    private func layoutIfManyCars() {
        carForServePicker.reloadAllComponents()
        carForServePicker.selectRow(cars.firstIndex(where: {$0.id == selectedCar?.id }) ?? 0,
                                    inComponent: 0, animated: false)
        layoutIfOneCar()
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
        let cell: ServiceCollectionViewCell = collectionView.dequeue(for: indexPath)
        let serviceType = serviceTypes[indexPath.row]
        cell.configure(name: serviceType.serviceTypeName, type: ControllerServiceType(rawValue: serviceType.controlTypeId) ?? .notDefined)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ServicesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.cellForItem(at: indexPath) as? ServiceCollectionViewCell != nil,
              let serviceType = ControllerServiceType(rawValue: serviceTypes[indexPath.row].controlTypeId) else {
                  return
              }

        let controller = ServiceModuleBuilder.buildController(serviceType: serviceTypes[indexPath.row],
                                                              for: serviceType, user: user)
        navigationController?.pushViewController(controller, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0.05 * Double(indexPath.row),
                       animations: { cell.alpha = 1 })
    }
}
