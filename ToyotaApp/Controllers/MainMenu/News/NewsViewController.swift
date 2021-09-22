import UIKit

class NewsViewController: UIViewController {
    @IBOutlet private var newsCollection: UICollectionView!

    private let refreshControl = UIRefreshControl()
    let cellIdentifier = CellIdentifiers.NewsCell

    private var user: UserProxy!
    private var news: [News] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: .pullToRefresh)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        newsCollection.refreshControl = refreshControl
        newsCollection.alwaysBounceVertical = true
        news = Test.createNews()
    }

    @IBAction func refresh() {
        refreshControl.beginRefreshing()
        news = Test.createNews()
        newsCollection.reloadData()
        endRefreshing()
    }

    private func endRefreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5,
                                      execute: { [self] in refreshControl.endRefreshing() })
    }
}

// MARK: - UICollectionViewDataSource
extension NewsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        news.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? NewsCollectionViewCell
        cell?.configure(with: news[indexPath.item])
        return cell!
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
