import UIKit

final class BookingsViewController: BaseViewController, Refreshable, BookingsView {
    private let interactor: BookingsInteractor

    let refreshableView: UITableView! = UITableView(frame: .zero, style: .insetGrouped)
    let refreshControl = UIRefreshControl()

    init(interactor: BookingsInteractor) {
        self.interactor = interactor

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshableView.dataSource = self
        interactor.view = self

        startRefreshing()
    }

    override func addViews() {
        addDismissRightButton()
        addSubviews(refreshableView)
        configureRefresh()
        refreshableView.tableFooterView = UIView()
        refreshableView.registerCell(BookingCell.self)
    }

    override func configureLayout() {
        refreshableView.edgesToSuperview()
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        refreshableView.allowsSelection = false
    }

    override func localize() {
        navigationItem.title = .common(.bookingsHistory)
    }

    func startRefreshing() {
        refreshControl.startRefreshing()
        interactor.getBookings()
    }

    func handleBookingsSuccess() {
        endRefreshing()
        refreshableView.reloadData()
        if interactor.bookings.isEmpty {
            refreshableView.setBackground(text: .background(.noBookings))
        }
    }

    func handleBookingsFailure(with message: String) {
        PopUp.display(.error(description: message))
        endRefreshing()
        refreshableView.setBackground(text: .background(.somethingWentWrong))
    }
}

// MARK: - UITableViewDataSource
extension BookingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        interactor.bookings.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BookingCell = tableView.dequeue(for: indexPath)
        cell.configure(with: interactor.bookings[indexPath.item])
        return cell
    }
}
