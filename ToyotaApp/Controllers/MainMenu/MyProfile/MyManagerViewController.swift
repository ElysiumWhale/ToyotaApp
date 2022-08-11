import UIKit

class MyManagerViewController: UIViewController {
    @IBOutlet private var managersCollection: UICollectionView!

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
                                   params: [(.auth(.userId), user.id),
                                            (.auth(.brandId), Brand.Toyota)],
                                   handler: managersRequestHandler)
    }

    private func handle(_ response: ManagersResponse) {
        managers = response.managers
        #if DEBUG
        if managers.isEmpty {
            managers = Mocks.createManagers()
        }
        #endif
        managersCollection.reloadData()
        if managers.isEmpty {
            managersCollection.setBackground(text: .background(.noManagers))
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MyManagerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        managers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ManagerCollectionViewCell = collectionView.dequeue(for: indexPath)
        cell.configure(from: managers[indexPath.row])
        return cell
    }
}

// MARK: - WithUserInfo
extension MyManagerViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}
