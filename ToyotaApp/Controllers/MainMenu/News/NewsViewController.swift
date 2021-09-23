import UIKit

class NewsViewController: RefreshableController {
    @IBOutlet private(set) var refreshableView: UICollectionView!

    private(set) var refreshControl = UIRefreshControl()
    let cellIdentifier = CellIdentifiers.NewsCell

    private var user: UserProxy!
    private var news: [News] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefresh()
        refreshableView.alwaysBounceVertical = true
        news = Test.createNews()
    }

    func startRefreshing() {
        refreshControl.beginRefreshing()
        news = Test.createNews()
        refreshableView.reloadData()
        endRefreshing()
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
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: { cell.alpha = 1 })
    }
}

// MARK: - WithUserInfo
extension NewsViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}
