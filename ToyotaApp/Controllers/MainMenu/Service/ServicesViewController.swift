import UIKit

    @IBOutlet private var carTextField: NoCopyPasteTexField!
    @IBOutlet private var showroomLabel: UILabel!
class ServicesViewController: RefreshableController, PickerController {
    @IBOutlet private(set) var refreshableView: UICollectionView!

    private(set) var refreshControl = UIRefreshControl()
    private var carForServePicker: UIPickerView = UIPickerView()

    private let cellIdentrifier = CellIdentifiers.ServiceCell

    private lazy var servicesTypesRequestHandler: RequestHandler<ServicesTypesResponse> = {
        let handler = RequestHandler<ServicesTypesResponse>()

        handler.onSuccess = { [weak self] data in
            DispatchQueue.main.async {
                self?.handle(success: data)
            }
        }

        handler.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.handle(failure: error)
            }
        }

        return handler
    }()

    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }

    private var cars: [Car] { user.getCars.array }
    private var selectedCar: Car? { user.getCars.defaultCar }
    private var serviceTypes: [ServiceType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.toyotaType(.regular, of: 17)
        ]
        carTextField.tintColor = .clear
        refreshableView.alwaysBounceVertical = true
        hideKeyboardWhenTappedAround()
        configurePicker(showroomPicker, with:  #selector(showroomDidSelect), for: showroomField)

        switch cars.count {
            case 1: layoutIfOneCar()
            case 2...: layoutIfManyCars()
            default: layoutIfNoCars()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if cars.isEmpty && !.noCarsMessageIsShown {
            PopUp.display(.warning(description: .error(.blockFunctionsAlert)))
            DefaultsManager.push(info: true, for: .noCarsMessage)
        }
    }

    func startRefreshing() {
        serviceTypes.removeAll()
        refreshableView.reloadData()
        refreshControl.startRefreshing()
        makeRequest()
    }

    @objc private func showroomDidSelect() {
        view.endEditing(true)
        let row = carForServePicker.selectedRow(inComponent: 0)
        if let car = selectedCar, car.id != cars[row].id,
           let showroomName = user.getSelectedShowroom?.showroomName {
            carTextField.text = "\(car.brand) \(car.model)"
            showroomLabel.text = showroomName
            user.updateSelected(car: cars[row])
            KeychainManager.set(Cars(cars))
            startRefreshing()
        }
    }

    private func handle(success response: ServicesTypesDidGetResponse) {
        serviceTypes = response.serviceType
        refreshableView.reloadData()
        endRefreshing()
        let text: String? = serviceTypes.isEmpty ? .background(.noServices) : nil
        refreshableView.setBackground(text: text)
    }

    private func handle(failure error: ErrorResponse) {
        let labelMessage = error.errorCode == .lostConnection ? .error(.networkError) + " и "
                                                              : .error(.servicesError) + ", "
        endRefreshing()
        refreshableView.setBackground(text: labelMessage + .common(.retryRefresh))
    }

    private func makeRequest() {
        // selectedCar.showroomId -> selectedShowroom
        NetworkService.makeRequest(page: .services(.getServicesTypes),
                                   params: [(.carInfo(.showroomId),
                                             selectedCar!.showroomId)],
                                   handler: servicesTypesRequestHandler)
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
        carTextField.isEnabled = false
        refreshControl.endRefreshing()
        refreshControl.isEnabled = false
        refreshableView.refreshControl = nil
        serviceTypes.removeAll()
        refreshableView.reloadData()
        showroomLabel.text = .empty
        carTextField.text = .empty
    }

    private func layoutIfOneCar() {
        configureRefresh()
        carTextField.text = "\(selectedCar!.brand) \(selectedCar!.model)"
        carTextField.isEnabled = cars.count > 1
        carTextField.layer.borderColor = UIColor.appTint(.secondarySignatureRed).cgColor
        carTextField.layer.borderWidth = 1
        carTextField.clipsToBounds = true
        showroomLabel.text = user.getSelectedShowroom!.showroomName
        refreshControl.beginRefreshing()
        makeRequest()
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
        cars[row].model.name
    }
}

// MARK: - UICollectionViewDataSource
extension ServicesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        serviceTypes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ServiceCollectionViewCell = collectionView.dequeue(for: indexPath)
        let serviceType = serviceTypes[indexPath.row]
        cell.configure(name: serviceType.serviceTypeName,
                       type: ControllerServiceType(rawValue: serviceType.controlTypeId) ?? .notDefined)
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

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0.05 * Double(indexPath.row),
                       animations: { cell.alpha = 1 })
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        animateCellBackground(collectionView, indexPath, color: .appTint(.secondarySignatureRed))
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        animateCellBackground(collectionView, indexPath, color: .appTint(.cell))
    }

    private func animateCellBackground(_ collectionView: UICollectionView, _ indexPath: IndexPath, color: UIColor) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
            cell.backgroundColor = color
        }
    }
}
