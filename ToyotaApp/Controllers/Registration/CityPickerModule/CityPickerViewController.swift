import UIKit

protocol CityPikerModule: UIViewController {
    var onCityPick: ParameterClosure<City>? { get set }
}

final class CityPickerViewController: BaseViewController,
                                      Refreshable,
                                      CityPikerModule {

    private let interactor: CityPickerInteractor

    private let subtitleLabel = UILabel()
    private let actionButton = CustomizableButton()

    let refreshableView = TableView<CityCell>(style: .insetGrouped)
    let refreshControl = UIRefreshControl()

    var onCityPick: ParameterClosure<City>?

    init(interactor: CityPickerInteractor) {
        self.interactor = interactor

        super.init()

        navigationItem.title = .common(.city)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        interactor.cities.isEmpty
            ? startRefreshing()
            : refreshableView.reloadData()
    }

    override func addViews() {
        addSubviews(subtitleLabel, refreshableView, actionButton)
        configureRefresh()
        refreshableView.delegate = self
        refreshableView.dataSource = self
    }

    override func configureLayout() {
        subtitleLabel.edgesToSuperview(excluding: .bottom,
                                       insets: .horizontal(20),
                                       usingSafeArea: true)
        refreshableView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        refreshableView.topToBottom(of: subtitleLabel)
        actionButton.centerXToSuperview()
        actionButton.size(.init(width: 245, height: 43))
        actionButton.bottomToSuperview(offset: -16, usingSafeArea: true)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        refreshableView.separatorColor = .appTint(.secondaryGray)
        refreshableView.allowsSelection = true
        refreshableView.alwaysBounceVertical = true
        refreshableView.backgroundColor = .systemBackground

        subtitleLabel.font = .toyotaType(.semibold, of: 23)
        subtitleLabel.textColor = .appTint(.signatureGray)

        actionButton.alpha = 0
        actionButton.rounded = true
        actionButton.titleLabel?.font = .toyotaType(.regular, of: 22)
        actionButton.normalColor = .appTint(.secondarySignatureRed)
        actionButton.highlightedColor = .appTint(.dimmedSignatureRed)
    }

    override func localize() {
        subtitleLabel.text = .common(.chooseCity)
        actionButton.setTitle(.common(.choose), for: .normal)
    }

    override func configureActions() {
        actionButton.addAction { [weak self] in
            self?.actionButtonDidPress()
        }
    }

    func startRefreshing() {
        refreshControl.startRefreshing()
        interactor.loadCities()
    }

    func handleSuccess() {
        actionButton.fadeOut()
        refreshableView.backgroundView = nil
        refreshableView.reloadData()
        endRefreshing()
    }

    func handleFailure() {
        refreshableView.reloadData()
        refreshableView.setBackground(text: .background(.noCities))
        endRefreshing()
    }

    private func actionButtonDidPress() {
        guard interactor.saveCity(),
              let selectedCity = interactor.selectedCity else {
            return
        }

        onCityPick?(selectedCity)
    }
}

// MARK: - UITableViewDelegate
extension CityPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if setCell(from: tableView, for: indexPath, isSelected: true) {
            interactor.selectCity(for: indexPath.row)
            actionButton.fadeIn()
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        setCell(from: tableView, for: indexPath, isSelected: false)
    }

    @discardableResult
    private func setCell(from tableView: UITableView, for indexPath: IndexPath, isSelected: Bool) -> Bool {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return false
        }

        cell.contentView.backgroundColor = isSelected
            ? .appTint(.secondarySignatureRed)
            : .appTint(.background)
        cell.contentConfiguration = .cellConfiguration(with: interactor.cities[indexPath.row].name,
                                                       isSelected: isSelected)
        return true
    }
}

// MARK: - UITableViewDataSource
extension CityPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        interactor.cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CityCell = tableView.dequeue(for: indexPath)

        cell.contentConfiguration = .cellConfiguration(with: interactor.cities[indexPath.row].name,
                                                       isSelected: false)
        return cell
    }
}
