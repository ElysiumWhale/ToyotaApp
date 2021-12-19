import UIKit

class BookingsViewController: RefreshableController {
    @IBOutlet private(set) var refreshableView: UITableView!

    let refreshControl = UIRefreshControl()

    private var bookings: [Booking] = []

    private lazy var handler: RequestHandler<BookingsResponse> = {
        var handler = RequestHandler<BookingsResponse>()

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
        refreshControl.beginRefreshing()
        NetworkService.makeRequest(page: .profile(.getBookings),
                                   params: [(.auth(.userId), KeychainManager<UserId>.get()?.id)],
                                   handler: handler)
    }

    private func handle(success response: BookingsResponse) {
        let formatter = DateFormatter.server
        bookings = response.booking
        #if DEBUG
        bookings.append(.mock)
        #endif
        bookings.sort(by: {
            formatter.date(from: $0.date) ?? Date() > formatter.date(from: $1.date) ?? Date()
        })

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

// MARK: - UITableViewDelegate
extension BookingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(
            withDuration: 0.1,
            delay: 0.05,
            animations: { cell.alpha = 1 })
    }
}
