import UIKit

class MyManagerViewController: UIViewController {
    @IBOutlet private var managersCollection: UICollectionView!

    private let cellIdentifier = CellIdentifiers.ManagerCell

    private var user: UserProxy!
    private var managers: [Manager] = []

    private lazy var managersRequestHandler: RequestHandler<ManagersResponse> = {
        RequestHandler<ManagersResponse>()
            .observe(on: .main)
            .bind { [weak self] data in
                self?.handle(data)
            } onFailure: { [weak self] error in
                self?.managersCollection.setBackground(text: error.message ?? .error(.managersLoadError))
            }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkService.makeRequest(page: .profile(.getManagers),
                                   params: [(.auth(.userId), user.getId),
                                            (.auth(.brandId), Brand.Toyota)],
                                   handler: managersRequestHandler)
    }

    private func handle(_ response: ManagersResponse) {
        managers = response.managers
        #if DEBUG
        if response.managers.isEmpty {
            managers = Mocks.createManagers()
        }
        #endif
        managersCollection.reloadData()
        if response.managers.isEmpty {
            managersCollection.setBackground(text: .background(.noManagers))
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MyManagerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        managers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ManagerCollectionViewCell = collectionView.dequeue(for: indexPath)
        cell.configure(from: managers[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MyManagerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0.05 * Double(indexPath.row),
                       animations: { cell.alpha = 1 })
    }
}

// MARK: - WithUserInfo
extension MyManagerViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}
