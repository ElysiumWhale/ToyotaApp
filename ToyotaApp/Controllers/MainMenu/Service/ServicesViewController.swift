import UIKit

class ServicesViewController: RefreshableController, PickerController {
    @IBOutlet private(set) var refreshableView: UICollectionView!
    @IBOutlet private var showroomField: NoCopyPasteTexField!
    @IBOutlet private var showroomIndicator: UIActivityIndicatorView!

    private(set) var refreshControl = UIRefreshControl()
    private var showroomPicker: UIPickerView = UIPickerView()

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

    private var carsCount: Int { user.getCars.array.count }
    private var showrooms: [Showroom] = []
    private var selectedShowroom: Showroom? = DefaultsManager.getUserInfo(for: .selectedShowroom) {
        didSet {
            showroomDidSet()
        }
    }
    private var selectedCity: City?
    private var serviceTypes: [ServiceType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.toyotaType(.regular, of: 17)
        ]
        showroomField.tintColor = .clear
        refreshableView.alwaysBounceVertical = true
        configureRefresh()
        hideKeyboardWhenTappedAround()
        configurePicker(showroomPicker, with: #selector(showroomDidSelect), for: showroomField)

        selectedCity = user.selectedCity
        if selectedCity != nil {
            showroomField.text = selectedShowroom?.name
            startRefreshing()
            loadShowrooms()
        } else {
            refreshableView.setBackground(text: .background(.noCityAndShowroom))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if user.getCars.array.isEmpty && !.noCarsMessageIsShown {
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
        if showrooms[showroomPicker.selectedRow].id == selectedShowroom?.id {
            return
        }

        selectedShowroom = showrooms[showroomPicker.selectedRow]
    }

    @IBAction func chooseCityDidTap() {
        view.endEditing(true)
        let board = UIStoryboard(.register)
        let vc: CityPickerViewController = board.instantiate(.cityPick)
        vc.setDelegate(self)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func handle(success response: ServicesTypesResponse) {
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
        NetworkService.makeRequest(page: .services(.getServicesTypes),
                                   params: [(.carInfo(.showroomId),
                                             selectedShowroom?.id)],
                                   handler: servicesTypesRequestHandler)
    }

    private func loadShowrooms() {
        showrooms = []
        NetworkService.makeRequest(page: .registration(.getShowrooms),
                                   params: [(.auth(.brandId), Brand.Toyota),
                                            (.carInfo(.cityId), selectedCity?.id)],
                                   handler: showroomsHandler)
    }

    private func showroomDidSet() {
        guard let showroom = selectedShowroom else {
            return
        }

        DefaultsManager.push(info: showroom, for: .selectedShowroom)
        DispatchQueue.main.async { [weak self] in
            self?.showroomField.text = showroom.name
            if let index = self?.showrooms.firstIndex(where: { $0.id == showroom.id }) {
                self?.showroomPicker.selectRow(index, inComponent: 0, animated: false)
            }
            self?.startRefreshing()
        }
    }

    private lazy var showroomsHandler: RequestHandler<ShowroomsResponse> = {
        let handler = RequestHandler<ShowroomsResponse>()

        handler.onSuccess = { [weak self] data in
            DispatchQueue.main.async {
                self?.handleShowrooms(response: data)
            }
        }

        handler.onFailure = { [weak self] error in
            // todo
        }

        return handler
    }()

    private func handleShowrooms(response: ShowroomsResponse) {
        showrooms = response.showrooms
        showroomField.placeholder = .common(.showroom)
        showroomPicker.reloadComponent(0)
        showroomIndicator.stopAnimating()
        guard !showrooms.contains(where: { $0.id == selectedShowroom?.id }) else {
            return
        }

        selectedShowroom = showrooms.first
    }
}

extension ServicesViewController: CityPickerDelegate {
    func cityDidSelect(_ city: City) {
        guard city.id != selectedCity?.id else {
            return
        }

        selectedCity = city
        showroomField.text = .empty
        showroomField.placeholder = .common(.showroomsLoading)
        showroomIndicator.startAnimating()
        loadShowrooms()
    }

    var cityPickButtonText: String {
        .common(.choose)
    }

    var dismissAfterPick: Bool {
        true
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
        }
    }
}

// MARK: - UIPickerViewDataSource
extension ServicesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        showrooms.count
    }
}

// MARK: - UIPickerViewDelegate
extension ServicesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        showrooms[row].name
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
        cell.configure(name: serviceType.serviceTypeName)
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
        collectionView.change(ServiceCollectionViewCell.self, at: indexPath) { cell in
            cell.backgroundColor = .appTint(.secondarySignatureRed)
            cell.serviceName.textColor = .white
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.change(ServiceCollectionViewCell.self, at: indexPath) { cell in
            cell.backgroundColor = .appTint(.cell)
            cell.serviceName.textColor = .appTint(.signatureGray)
        }
    }
}
