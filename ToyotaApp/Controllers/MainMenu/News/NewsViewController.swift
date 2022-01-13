import UIKit
import SafariServices

class NewsViewController: RefreshableController {
    @IBOutlet private(set) var refreshableView: UITableView!

    private(set) var refreshControl = UIRefreshControl()

    private var user: UserProxy!
    private var news: [News] = []
    private var selectedRow: IndexPath?
    private var selectedShowroom: Showroom? = DefaultsManager.getUserInfo(for: .selectedShowroom)
    private var url: ShowroomsUrl {
        guard let selectedShowroom = selectedShowroom else {
            return ShowroomsUrl.samaraAurora
        }

        return ShowroomsUrl(rawValue: selectedShowroom.id) ?? .samaraAurora
    }

    private lazy var parser = HtmlParser(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.toyotaType(.regular, of: 17)
        ]
        configureRefresh()
        refreshableView.alwaysBounceVertical = true
        startRefreshing()
    }

    func startRefreshing() {
        refreshControl.startRefreshing()
        parser.start(with: url)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedRow = selectedRow {
            refreshableView.deselectRow(at: selectedRow, animated: true)
        }

        if let newShowroom: Showroom = DefaultsManager.getUserInfo(for: .selectedShowroom),
           newShowroom.id != selectedShowroom?.id {
            news = []
            refreshableView.reloadData()
            selectedShowroom = newShowroom
            startRefreshing()
        }
    }
}

// MARK: - UITableViewDelegate
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = news[indexPath.row].url {
            selectedRow = indexPath
            navigationController?.present(SFSafariViewController(url: url),
                                          animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsTableViewCell = tableView.dequeue(for: indexPath)
        cell.configure(with: news[indexPath.item])
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }
}

// MARK: - ParserDelegate
extension NewsViewController: ParserDelegate {
    func errorDidReceive(_ error: Error) {
        news = []
        refreshableView.reloadData()
        endRefreshing()
        refreshableView.setBackground(text: .error(.newsError))
    }

    func newsDidLoad(_ loadedNews: [News]) {
        news = loadedNews
        refreshableView.reloadData()
        let text: String? = loadedNews.isEmpty ? .background(.noNews) : nil
        refreshableView.setBackground(text: text)
        endRefreshing()
    }
}

// MARK: - WithUserInfo
extension NewsViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}
