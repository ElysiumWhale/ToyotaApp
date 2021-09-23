import UIKit

class BookingsViewController: RefreshableController, BackgroundText {
    @IBOutlet private(set) var refreshableView: UITableView!

    private let cellIdentifier = CellIdentifiers.BookingCell
    private(set) var refreshControl = UIRefreshControl()

    private var bookings: [Booking] = []

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
        NetworkService.makePostRequest(page: .profile(.getBookings),
                                       params: [URLQueryItem(.auth(.userId), KeychainManager.get(UserId.self)?.id)],
                                       completion: bookingsDidDownloadCompletion)
    }

    private func bookingsDidDownload(_ response: Result<BookingsResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                let serverFormatter = DateFormatter.server
                bookings = data.booking
                #if DEBUG
                bookings.append(.mock)
                #endif
                bookings.sort(by: { serverFormatter.date(from: $0.date) ?? Date() > serverFormatter.date(from: $1.date) ?? Date() })
                DispatchQueue.main.async { [weak self] in
                    guard let controller = self else { return }
                    controller.endRefreshing()
                    controller.refreshableView.reloadData()
                    if controller.bookings.isEmpty {
                        controller.refreshableView.backgroundView = controller.createBackground(labelText: "На данный момент нет ни одного обращения.")
                    }
                }
            case .failure(let error):
                PopUp.display(.error(description: error.message ?? AppErrors.requestError.rawValue))
                DispatchQueue.main.async { [weak self] in
                    self?.endRefreshing()
                    self?.refreshableView.backgroundView = self?.createBackground(labelText: "Что то пошло не так...")
                }
        }
    }
}

// MARK: - UITableViewDataSource
extension BookingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BookingCell
        cell?.configure(with: bookings[indexPath.item])
        return cell!
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
