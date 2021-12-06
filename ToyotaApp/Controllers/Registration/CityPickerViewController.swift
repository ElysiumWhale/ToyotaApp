import UIKit

class CityPickerViewController: RefreshableController, CityPickerView, BackgroundText {
    @IBOutlet private(set) var refreshableView: UITableView!
    @IBOutlet private var nextButton: CustomizableButton!

    let refreshControl = UIRefreshControl()

    private let viewModel = CityPickerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self

        nextButton.alpha = 0
        refreshableView.delegate = self
        refreshableView.dataSource = self
        configureRefresh()
        viewModel.cities.isEmpty ? startRefreshing() : refreshableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.code {
            // todo: switch for different types
            default:
                return
        }
    }

    func startRefreshing() {
        refreshControl.beginRefreshing()
        viewModel.loadCities()
    }

    func configure(with cities: [City]) {
        viewModel.configure(with: cities)
    }

    func handleSuccess() {
        nextButton.fadeOut()
        refreshableView.backgroundView = nil
        refreshableView.reloadData()
        endRefreshing()
    }

    func handleFailure() {
        refreshableView.reloadData()
        refreshableView.backgroundView = createBackground(labelText: .background(.noCities))
        endRefreshing()
    }

    @IBAction private func nextButtonDidPress(sender: UIButton?) {
        guard viewModel.saveCity() else {
            return
        }

        // todo: perform(segue: )
    }
}

// MARK: - UITableViewDataSource
extension CityPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CityCell = tableView.dequeue(for: indexPath)
        cell.contentConfiguration = .cellConfiguration(with: viewModel.cities[indexPath.row].name,
                                                       isSelected: false)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CityPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if setCell(from: tableView, for: indexPath, isSelected: true) {
            viewModel.selectCity(for: indexPath.row)
            nextButton.fadeIn()
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

        cell.backgroundColor = isSelected
            ? .appTint(.secondarySignatureRed)
            : .appTint(.background)
        cell.contentConfiguration = .cellConfiguration(with: viewModel.cities[indexPath.row].name,
                                                       isSelected: isSelected)
        return true
    }
}
