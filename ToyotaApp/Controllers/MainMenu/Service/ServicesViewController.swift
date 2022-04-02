import UIKit

private enum ServiceSections: Int {
    case main
}

private typealias DataSource<T1: Hashable, T2: Hashable> = UICollectionViewDiffableDataSource<T1, T2>

class ServicesViewController: RefreshableController, PickerController {
    @IBOutlet private var showroomField: NoCopyPasteTexField!

    private(set) lazy var refreshableView: UICollectionView! = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: makeCompositionalLayout())
        collectionView.backgroundColor = .appTint(.background)
        return collectionView
    }()

    private(set) var refreshControl = UIRefreshControl()
    private let showroomIndicator = UIActivityIndicatorView(style: .medium)
    private let showroomPicker = UIPickerView()

    private lazy var dataSource: DataSource<ServiceSections, ServiceType.ID> = configureDataSource()

    private lazy var chevronButton: UIButton = .imageButton { [weak self] in
        self?.showroomField.becomeFirstResponder()
    }

    private let interactor = ServicesInteractor()

    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }

    private var carsCount: Int { user.cars.value.count }

    private var fieldHeight: CGFloat {
        showroomField.frame.height
    }

    // MARK: - Public methods
    override func viewDidLoad() {
        super.viewDidLoad()

        interactor.view = self
        configureShowroomField()
        configureCollectionView()
        hideKeyboardWhenTappedAround()

        navigationItem.titleView = .titleViewFor(city: interactor.selectedCity?.name,
                                                 action: chooseCityDidTap)
        if interactor.selectedCity != nil {
            showroomField.text = interactor.selectedShowroom?.name
            startRefreshing()
            interactor.loadShowrooms()
        } else {
            refreshableView.setBackground(text: .background(.noCityAndShowroom))
        }
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

    // MARK: - Private methods
    @objc private func showroomDidSelect() {
        view.endEditing(true)
        interactor.selectShowroom(for: showroomPicker.selectedRow)
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
        showroomField.setRightView(from: chevronButton, width: 30,
                                   height: fieldHeight)
        configurePicker(showroomPicker, with: #selector(showroomDidSelect), for: showroomField)
    }

    private func configureCollectionView() {
        view.addSubview(refreshableView)
        refreshableView.edgesToSuperview(excluding: .top)
        refreshableView.topToBottom(of: showroomField)
        configureRefresh()
        refreshableView.delegate = self
        refreshableView.dataSource = dataSource
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
}

// MARK: - CityPickerDelegate
extension ServicesViewController: CityPickerDelegate {
    func cityDidSelect(_ city: City) {
        if let selectedCity = interactor.selectedCity, city.id == selectedCity.id {
            return
        }

        navigationItem.titleView?.setTitleIfButtonFirst(city.name)
        interactor.selectedCity = city
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

// MARK: - WithUserInfo
extension ServicesViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }

    func subscribe(on proxy: UserProxy) {
        proxy.notificator.add(observer: self)
    }

    func unsubscribe(from proxy: UserProxy) {
        proxy.notificator.remove(obsever: self)
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

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0.05 * Double(indexPath.row),
                       animations: { cell.alpha = 1 })
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

// MARK: - UICollectionViewDelegateFlowLayout
extension ServicesViewController: UICollectionViewDelegateFlowLayout {
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 10, leading: 8, bottom: 10, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)

        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
