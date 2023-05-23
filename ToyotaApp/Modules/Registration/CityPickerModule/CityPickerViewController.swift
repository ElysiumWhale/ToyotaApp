import UIKit
import DesignKit
import ComposableArchitecture
import Combine

final class CityPickerViewController: BaseViewController, Refreshable {

    private let viewStore: ViewStoreOf<CityPickerFeature>

    private let subtitleLabel = UILabel()
    private let actionButton = CustomizableButton(.toyotaAction())

    let refreshableView = TableView<CityCell>(style: .insetGrouped)
    let refreshControl = UIRefreshControl()

    private var cancellables: Set<AnyCancellable> = []

    init(store: StoreOf<CityPickerFeature>) {
        self.viewStore = ViewStore(store)

        super.init()
        setupSubscriptions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if viewStore.cities.isEmpty {
            startRefreshing()
        } else {
            refreshableView.reloadData()
        }
    }

    override func addViews() {
        addSubviews(subtitleLabel, refreshableView, actionButton)
        configureRefresh()
        refreshableView.delegate = self
        refreshableView.dataSource = self
    }

    override func configureLayout() {
        subtitleLabel.edgesToSuperview(
            excluding: .bottom,
            insets: .horizontal(20),
            usingSafeArea: true
        )
        refreshableView.edgesToSuperview(
            excluding: .top,
            usingSafeArea: true
        )
        refreshableView.topToBottom(of: subtitleLabel)
        actionButton.centerXToSuperview()
        actionButton.size(.toyotaActionL)
        actionButton.bottomToSuperview(
            offset: -16,
            usingSafeArea: true
        )
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        refreshableView.separatorColor = .appTint(.secondaryGray)
        refreshableView.allowsSelection = true
        refreshableView.alwaysBounceVertical = true
        refreshableView.backgroundColor = view.backgroundColor

        subtitleLabel.font = .toyotaType(.semibold, of: 23)
        subtitleLabel.textColor = .appTint(.signatureGray)
        subtitleLabel.backgroundColor = view.backgroundColor

        actionButton.alpha = 0
    }

    override func localize() {
        navigationItem.title = .common(.city)
        subtitleLabel.text = .common(.chooseCity)
        actionButton.setTitle(.common(.choose), for: .normal)
    }

    override func configureActions() {
        actionButton.addAction { [weak self] in
            self?.viewStore.send(.chooseButtonDidPress)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        viewStore.send(.cancelTasks)
    }

    func startRefreshing() {
        viewStore.send(.loadCities)
    }

    private func setupSubscriptions() {
        viewStore.publisher.cities
            .sinkOnMain { [unowned self] cities in
                refreshableView.reloadData()
                refreshableView.setBackground(cities.isEmpty
                    ? .label(.background(.noCities), .toyotaType(.semibold, of: 25))
                    : .empty
                )
            }
            .store(in: &cancellables)

        viewStore.publisher.isLoading
            .sinkOnMain { [unowned self] in
                $0 ? refreshControl.startRefreshing() : endRefreshing()
            }
            .store(in: &cancellables)

        viewStore.publisher.popupMessage
            .compactMap { $0 }
            .sinkOnMain { [unowned self] in
                PopUp.display(.error($0))
                viewStore.send(.popupDidShow)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDelegate
extension CityPickerViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if setCell(from: tableView, for: indexPath, isSelected: true) {
            viewStore.send(.cityDidSelect(index: indexPath.row))
            actionButton.fadeIn()
        }
    }

    func tableView(
        _ tableView: UITableView,
        didDeselectRowAt indexPath: IndexPath
    ) {
        setCell(from: tableView, for: indexPath, isSelected: false)
    }

    @discardableResult
    private func setCell(
        from tableView: UITableView,
        for indexPath: IndexPath,
        isSelected: Bool
    ) -> Bool {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return false
        }

        cell.contentView.backgroundColor = isSelected
            ? .appTint(.secondarySignatureRed)
            : .appTint(.background)
        cell.contentConfiguration = .cellConfiguration(
            with: viewStore.cities[safe: indexPath.row]?.name,
            isSelected: isSelected
        )
        return true
    }
}

// MARK: - UITableViewDataSource
extension CityPickerViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewStore.cities.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: CityCell = tableView.dequeue(for: indexPath)
        cell.contentConfiguration = .cellConfiguration(
            with: viewStore.cities[safe: indexPath.row]?.name,
            isSelected: false
        )
        return cell
    }
}
