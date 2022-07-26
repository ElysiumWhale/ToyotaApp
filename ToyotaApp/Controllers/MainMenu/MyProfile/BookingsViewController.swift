import UIKit

class BookingsViewController: RefreshableController {
    @IBOutlet private(set) var refreshableView: UITableView!

    let refreshControl = UIRefreshControl()

    private var bookings: [Booking] = []

    private lazy var handler: RequestHandler<BookingsResponse> = {
        RequestHandler<BookingsResponse>()
            .observe(on: .main)
            .bind { [weak self] data in
                self?.handle(success: data)
            } onFailure: { [weak self] error in
                self?.handle(failure: error)
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefresh()
        refreshableView.tableFooterView = UIView()
        startRefreshing()
    }

    @IBAction func doneDidPressed(_ sender: Any) {
        dismiss(animated: true)
    }

    func startRefreshing() {
        refreshControl.startRefreshing()
        NetworkService.makeRequest(page: .profile(.getBookings),
                                   params: .userId,
                                   handler: handler)
    }

    private func handle(success response: BookingsResponse) {
        #if DEBUG
        var list = response.booking
        list.append(.todayNotInFuture)
        let response = BookingsResponse(result: .common(.ok).lowercased(), booking: list, count: list.count)
        #endif
        bookings = response.booking.sorted(by: { $0.date > $1.date })
        endRefreshing()
        refreshableView.reloadData()
        if bookings.isEmpty {
            refreshableView.setBackground(text: .background(.noBookings))
        }
    }

    private func handle(failure response: ErrorResponse) {
        PopUp.display(.error(description: response.message ?? .error(.requestError)))
        endRefreshing()
        refreshableView.setBackground(text: .background(.somethingWentWrong))
    }
}

// MARK: - UITableViewDataSource
extension BookingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BookingCell = tableView.dequeue(for: indexPath)
        cell.configure(with: bookings[indexPath.item])
        return cell
    }
}
