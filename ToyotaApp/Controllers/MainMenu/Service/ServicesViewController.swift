import UIKit

class ServicesViewController: RefreshableController, PickerController {
    @IBOutlet private(set) var refreshableView: UICollectionView!
    @IBOutlet private var showroomField: NoCopyPasteTexField!

    private(set) var refreshControl = UIRefreshControl()
    private let showroomIndicator = UIActivityIndicatorView(style: .medium)
    private let showroomPicker = UIPickerView()

    private let interactor = ServicesInteractor()

    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }

    private var carsCount: Int { user.getCars.array.count }

    private var fieldHeight: CGFloat {
        showroomField.frame.height
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.view = self
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.toyotaType(.regular, of: 17)
        ]

        configureShowroomField()
        configureRefresh()
        hideKeyboardWhenTappedAround()

        navigationItem.titleView = UIButton.forCity(title: interactor.selectedCity?.name,
                                                    action: chooseCityDidTap)
        if interactor.selectedCity != nil {
            showroomField.text = interactor.selectedShowroom?.name
            startRefreshing()
            interactor.loadShowrooms()
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
        view.endEditing(true)
        refreshControl.startRefreshing()
        if interactor.showrooms.isEmpty && interactor.selectedShowroom == nil {
            showroomIndicator.startAnimating()
            showroomField.setRightView(from: showroomIndicator, width: 30,
                                       height: fieldHeight)
            interactor.loadShowrooms()
        } else {
            interactor.loadServiceTypes()
        }
    }

    @objc private func showroomDidSelect() {
        view.endEditing(true)

        let newShowroom = interactor.showrooms[showroomPicker.selectedRow]
        if newShowroom.id == interactor.selectedShowroom?.id {
            return
        }
        interactor.selectedShowroom = newShowroom
    }

    @IBAction private func chooseCityDidTap() {
        view.endEditing(true)
        let vc: CityPickerViewController = UIStoryboard(.register).instantiate(.cityPick)
        vc.setDelegate(self)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func configureShowroomField() {
        showroomField.tintColor = .clear
        showroomField.rightViewMode = .always
        showroomField.setRightView(from: button, width: 30,
                                   height: fieldHeight)
        configurePicker(showroomPicker, with: #selector(showroomDidSelect), for: showroomField)
    }

    private lazy var button: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "chevron.down")
        button.setImage(image?.applyingSymbolConfiguration(.init(scale: .large)),
                        for: .normal)
        button.imageView?.tintColor = .appTint(.secondarySignatureRed)
        button.addAction { [weak self] in
            self?.showroomField.becomeFirstResponder()
        }
        return button
    }()
}

// MARK: - CityPickerDelegate
extension ServicesViewController: CityPickerDelegate {
    func cityDidSelect(_ city: City) {
        if let selectedCity = interactor.selectedCity, city.id == selectedCity.id {
            return
        }

        (navigationItem.titleView as? UIButton)?.setTitle(city.name + " ▸", for: .normal)
        interactor.selectedCity = city
        interactor.selectedShowroom = nil
        showroomField.text = .empty
        showroomField.placeholder = .common(.showroomsLoading)
        showroomIndicator.startAnimating()
        showroomField.setRightView(from: showroomIndicator, width: 30,
                                   height: fieldHeight)
        interactor.loadShowrooms()
    }

    var cityPickButtonText: String {
        .common(.choose)
    }

    var dismissAfterPick: Bool {
        true
    }
}

// MARK: - ServicesView
extension ServicesViewController: ServicesView {
    func didSelect(showroom: Showroom, with index: Int?) {
        self.showroomField.text = showroom.name
        if let index = index {
            showroomPicker.selectRow(index, inComponent: 0, animated: false)
        }
        startRefreshing()
    }

    // MARK: - Success loading
    func didLoadShowrooms() {
        view.endEditing(true)
        showroomField.placeholder = .common(.showroom)
        showroomPicker.reloadComponent(0)
        showroomPicker.selectRow(interactor.selectedShowroomIndex ?? 0,
                                 inComponent: 0,
                                 animated: false)
        if showroomIndicator.isAnimating {
            showroomIndicator.stopAnimating()
        }
        showroomField.setRightView(from: button, width: 30,
                                   height: fieldHeight)
    }

    func didLoadServiceTypes() {
        refreshableView.reloadData()
        endRefreshing()
        let background: String? = interactor.serviceTypes.isEmpty ? .background(.noServices) : nil
        refreshableView.setBackground(text: background)
    }

    // MARK: - Failure loading
    func didFailShowrooms(with error: String) {
        if showroomIndicator.isAnimating {
            showroomIndicator.stopAnimating()
        }
        showroomField.rightView = nil
        endRefreshing()
        showroomPicker.reloadComponent(0)
        showroomField.text = .empty
        showroomField.placeholder = "Ошибка"
        refreshableView.setBackground(text: error + .common(.pullToRefresh))
    }

    func didFailServiceTypes(with error: String) {
        endRefreshing()
        refreshableView.setBackground(text: error)
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
}

// MARK: - UIPickerViewDataSource
extension ServicesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        interactor.showrooms.count
    }
}

// MARK: - UIPickerViewDelegate
extension ServicesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        interactor.showrooms[row].name
    }
}

// MARK: - UICollectionViewDataSource
extension ServicesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        interactor.serviceTypes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ServiceCollectionViewCell = collectionView.dequeue(for: indexPath)
        let serviceType = interactor.serviceTypes[indexPath.row]
        cell.configure(name: serviceType.serviceTypeName)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ServicesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let service = interactor.serviceTypes[indexPath.row]
        guard let controllerType = ControllerServiceType(rawValue: service.controlTypeId) else {
            return
        }

        let controller = ServiceModuleBuilder.buildModule(serviceType: service,
                                                          for: controllerType,
                                                          user: user)
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
