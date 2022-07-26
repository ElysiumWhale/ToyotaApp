import UIKit

private enum ServiceSections: Int {
    case main
}

private typealias DataSource<T1: Hashable, T2: Hashable> = UICollectionViewDiffableDataSource<T1, T2>

class ServicesViewController: InitialazableViewController, Refreshable {
    let showroomField = NoCopyPasteTexField()
    let refreshControl = UIRefreshControl()

    private(set) lazy var refreshableView: UICollectionView! = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: .servicesLayout)
        collectionView.backgroundColor = .appTint(.blackBackground)
        collectionView.delegate = self
        return collectionView
    }()

    private let showroomIndicator = UIActivityIndicatorView(style: .medium)
    private let showroomPicker = UIPickerView()

    private lazy var dataSource: DataSource<ServiceSections, ServiceType.ID> = configureDataSource()

    private lazy var chevronButton: UIButton = .imageButton { [weak self] in
        self?.showroomField.becomeFirstResponder()
    }

    private let interactor: ServicesInteractor
    private let user: UserProxy

    private var carsCount: Int { user.cars.value.count }

    private var fieldHeight: CGFloat {
        showroomField.frame.height
    }

    init(user: UserProxy, interactor: ServicesInteractor = .init()) {
        self.user = user
        self.interactor = interactor
        super.init()

        interactor.view = self
    }

    // MARK: - Public methods
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        configureRefresh()
        refreshableView.dataSource = dataSource

        if interactor.selectedCity != nil {
            showroomField.text = interactor.selectedShowroom?.name
            startRefreshing()
            interactor.loadShowrooms()
        } else {
            refreshableView.setBackground(text: .background(.noCityAndShowroom))
        }
    }

    override func addViews() {
        addSubviews(showroomField, refreshableView)
        navigationItem.titleView = .titleViewFor(city: interactor.selectedCity?.name,
                                                 action: chooseCityDidTap)
        let chatButton = UIBarButtonItem(image: .chat.withTintColor(.appTint(.secondarySignatureRed)),
                                         style: .plain,
                                         target: self,
                                         action: #selector(chatButtonDidPress))
        navigationItem.setRightBarButton(chatButton, animated: false)
        showroomField.setRightView(from: chevronButton, width: 30,
                                   height: fieldHeight)
    }

    override func configureLayout() {
        showroomField.edgesToSuperview(excluding: .bottom,
                                       insets: .uniform(16),
                                       usingSafeArea: true)
        showroomField.height(45)
        refreshableView.edgesToSuperview(excluding: .top)
        refreshableView.topToBottom(of: showroomField, offset: 8)
    }

    override func localize() {
        showroomField.placeholder = .common(.showroom)
        navigationItem.backButtonTitle = .common(.services)
    }

    override func configureAppearance() {
        configureNavBarAppearance(font: nil)
        view.backgroundColor = .appTint(.blackBackground)
        showroomField.textAlignment = .center
        showroomField.font = .toyotaType(.light, of: 25)
        showroomField.textColor = .appTint(.signatureGray)
        showroomField.cornerRadius = 10
        showroomField.minimumFontSize = 17
        showroomField.adjustsFontSizeToFitWidth = true
        showroomField.backgroundColor = .appTint(.cell)
        showroomField.tintColor = .clear
        showroomField.rightViewMode = .always
    }

    override func configureActions() {
        showroomPicker.configure(delegate: self,
                                 with: #selector(showroomDidSelect),
                                 for: showroomField)
    }

    func startRefreshing() {
        view.endEditing(true)
        refreshControl.startRefreshing()
        if interactor.selectedCity == nil {
            refreshableView.setBackground(text: .background(.noCityAndShowroom))
            endRefreshing()
        } else if interactor.showrooms.isEmpty && interactor.selectedShowroom == nil {
            showroomIndicator.startAnimating()
            showroomField.setRightView(from: showroomIndicator, width: 30,
                                       height: fieldHeight)
            interactor.loadShowrooms()
        } else {
            interactor.loadServiceTypes()
        }
    }

    func cityDidSelect(_ city: City) {
        navigationItem.titleView?.setTitleIfButtonFirst(city.name)
        showroomField.text = .empty
        showroomField.placeholder = .common(.showroomsLoading)
        showroomIndicator.startAnimating()
        showroomField.setRightView(from: showroomIndicator, width: 30,
                                   height: fieldHeight)
        interactor.loadShowrooms()
    }

    // MARK: - Private methods
    @objc private func showroomDidSelect() {
        view.endEditing(true)
        interactor.selectShowroom(for: showroomPicker.selectedRow)
    }

    @IBAction private func chooseCityDidTap() {
        view.endEditing(true)

        let cityPickerModule = RegisterFlow.cityModule()
        cityPickerModule.hidesBottomBarWhenPushed = true
        cityPickerModule.onCityPick = { [weak self] city in
            self?.navigationController?.popViewController(animated: true)
            self?.cityDidSelect(city)
        }

        navigationController?.pushViewController(cityPickerModule, animated: true)
    }

    @discardableResult
    private func configureDataSource() -> DataSource<ServiceSections, ServiceType.ID> {
        let cellRegistration = UICollectionView.CellRegistration<ServiceTypeCell, ServiceType> { cell, _, serviceType in

            cell.configure(name: serviceType.serviceTypeName)
        }

        return DataSource(collectionView: refreshableView) { collectionView, indexPath, _ -> UICollectionViewCell in

            let serviceType = self.interactor.serviceTypes[indexPath.row]
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: serviceType)
        }
    }

    @objc private func chatButtonDidPress() {
        navigationController?.pushViewController(MainMenuFlow.chatModule(),
                                                 animated: true)
    }
}

// MARK: - ServicesView
extension ServicesViewController: ServicesView {
    func didSelect(showroom: Showroom, with index: Int?) {
        showroomField.text = showroom.name
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
        showroomField.setRightView(from: chevronButton, width: 30,
                                   height: fieldHeight)
    }

    func didLoadServiceTypes() {
        let servicesIds = interactor.serviceTypes.map { $0.id }
        var snapshot = NSDiffableDataSourceSnapshot<ServiceSections, ServiceType.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(servicesIds, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)

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
        showroomField.placeholder = .common(.error)
        refreshableView.setBackground(text: error + .common(.pullToRefresh))
    }

    func didFailServiceTypes(with error: String) {
        endRefreshing()
        refreshableView.setBackground(text: error)
    }
}

// MARK: - UIPickerViewDataSource
extension ServicesViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        interactor.showrooms.isEmpty ? 1 : interactor.showrooms.count
    }
}

// MARK: - UIPickerViewDelegate
extension ServicesViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        interactor.showrooms.isEmpty
            ? .common(.noShoworooms)
            : interactor.showrooms[row].name
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

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.change(ServiceTypeCell.self, at: indexPath) { cell in
            cell.backgroundColor = .appTint(.secondarySignatureRed)
            cell.typeNameLabel.textColor = .white
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.change(ServiceTypeCell.self, at: indexPath) { cell in
            cell.backgroundColor = .appTint(.cell)
            cell.typeNameLabel.textColor = .appTint(.signatureGray)
        }
    }
}
