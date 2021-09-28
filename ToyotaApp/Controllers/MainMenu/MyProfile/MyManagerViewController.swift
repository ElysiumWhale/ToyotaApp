import UIKit

class MyManagerViewController: UIViewController, BackgroundText {
    @IBOutlet private var managersCollection: UICollectionView!

    private let cellIdentifier = CellIdentifiers.ManagerCell

    private var user: UserProxy!
    private var managers: [Manager] = []

    private lazy var managersRequestHandler: RequestHandler<ManagersDidGetResponse> = {
        let handler = RequestHandler<ManagersDidGetResponse>()
        
        handler.onSuccess = { [weak self] data in
            DispatchQueue.main.async {
                self?.handle(data)
            }
        }
        
        handler.onFailure = { [weak self] error in
            DispatchQueue.main.async {
                self?.managersCollection.backgroundView = self?.createBackground(labelText: error.message ?? .error(.managersLoadError))
            }
        }
        
        return handler
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let params = [URLQueryItem(.auth(.userId), user.getId),
                      URLQueryItem(.auth(.brandId), Brand.Toyota)]
        NetworkService.makeRequest(page: .profile(.getManagers),
                                   params: params, handler: managersRequestHandler)
    }

    @IBAction func doneDidPress(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func handle(_ response: ManagersDidGetResponse) {
        managers = response.managers
        managersCollection.reloadData()
        if response.managers.isEmpty {
            managersCollection.backgroundView = createBackground(labelText: .background(.noManagers))
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
