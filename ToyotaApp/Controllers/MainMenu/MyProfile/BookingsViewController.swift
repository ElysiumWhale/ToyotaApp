import UIKit

class BookingsViewController: UIViewController, BackgroundText {
    @IBOutlet private var bookingsTable: UITableView!

    private let cellIdentifier = CellIdentifiers.BookingCell
    private let refreshControl = UIRefreshControl()

    private var bookings: [Booking] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: CommonText.pullToRefresh)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        bookingsTable.refreshControl = refreshControl
        bookingsTable.tableFooterView = UIView()
        refresh(nil)
    }

    @IBAction func doneDidPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func refresh(_ sender: Any?) {
        refreshControl.beginRefreshing()
        NetworkService.shared.makePostRequest(page: .profile(.getBookings),
                                              params: [URLQueryItem(.auth(.userId), KeychainManager.get(UserId.self)?.id)],
                                              completion: bookingsDidDownloadCompletion)
    }
    
    private func endRefreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5,
                                      execute: { [weak self] in self?.refreshControl.endRefreshing() })
    }
    
    private func bookingsDidDownloadCompletion(_ response: Result<BookingsResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                let serverFormatter = DateFormatter.server
                bookings = data.booking
                bookings.append(Booking(date: "2021.09.11", startTime: "21", latitude: "",
                                        longitude: "", status: "0", carName: "Land Cruiser 300",
                                        licensePlate: "А344РС163RUS", showroomName: "Тойота Самара Юг",
                                        serviceName: "Плановый технический осмотр", postName: "Samara Gorod"))
                bookings.sort(by: { serverFormatter.date(from: $0.date) ?? Date() > serverFormatter.date(from: $1.date) ?? Date() })
                DispatchQueue.main.async { [weak self] in
                    guard let controller = self else { return }
                    controller.endRefreshing()
                    controller.bookingsTable.reloadData()
                    if controller.bookings.isEmpty {
                        controller.bookingsTable.backgroundView = controller.createBackground(labelText: "На данный момент нет ни одного обращения.")
                    }
                }
            case .failure(let error):
                PopUp.display(.error(description: error.message ?? AppErrors.requestError.rawValue))
                DispatchQueue.main.async { [weak self] in
                    self?.endRefreshing()
                    self?.bookingsTable.backgroundView = self?.createBackground(labelText: "Что то пошло не так...")
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
            delay: 0.05 * Double(indexPath.row),
            animations: { cell.alpha = 1 })
    }
}
