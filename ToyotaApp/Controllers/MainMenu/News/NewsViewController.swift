import UIKit
import SafariServices

class NewsViewController: RefreshableController, BackgroundText {
    @IBOutlet private(set) var refreshableView: UICollectionView!

    private(set) var refreshControl = UIRefreshControl()
    let cellIdentifier = CellIdentifiers.NewsCell

    private var user: UserProxy!
    private var news: [News] = []

    private var parser: HtmlParser?
    
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
        refreshControl.beginRefreshing()
        setTitle(with: .common(.loading))
        parser = HtmlParser(delegate: self)
        parser?.start()
    }
}

// MARK: - UICollectionViewDataSource
extension NewsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        news.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NewsCollectionViewCell = collectionView.dequeue(for: indexPath)
        cell.configure(with: news[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension NewsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = news[indexPath.row].url {
            navigationController?.present(SFSafariViewController(url: url),
                                          animated: true)
        }
    }
}

// MARK: - ParserDelegate
extension NewsViewController: ParserDelegate {
    func errorDidReceive(_ error: Error) {
        news = []
        refreshableView.reloadData()
        endRefreshing()
        refreshableView.backgroundView = createBackground(labelText: .error(.newsError))
    }

    func newsDidLoad(_ loadedNews: [News]) {
        news = loadedNews
        refreshableView.reloadData()
        refreshableView.backgroundView = loadedNews.isEmpty ? nil : createBackground(labelText: .background(.noNews))
        endRefreshing()
    }
}

// MARK: - WithUserInfo
extension NewsViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}
