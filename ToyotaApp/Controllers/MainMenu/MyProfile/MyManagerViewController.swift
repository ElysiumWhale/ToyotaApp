import UIKit

class MyManagerViewController: UIViewController, BackgroundText {
    @IBOutlet private var managersCollection: UICollectionView!

    private let cellIdentifier = CellIdentifiers.ManagerCell

    private var user: UserProxy!
    private var managers: [Manager] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let params = [URLQueryItem(.auth(.userId), user.getId),
                      URLQueryItem(.auth(.brandId), Brand.Toyota)]
        NetworkService.makePostRequest(page: .profile(.getManagers),
                                       params: params, completion: completion)
        
        func completion(for response: Result<ManagersDidGetResponse, ErrorResponse>) {
            switch response {
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        if let mes = error.message {
                            PopUp.display(.error(description: mes))
                        }
                        self?.managersCollection.backgroundView = self?.createBackground(labelText: error.message ?? .error(.managersLoadError))
                    }
                case .success(let data):
                    managers = data.managers
                    DispatchQueue.main.async { [weak self] in
                        self?.managersCollection.reloadData()
                        if data.managers.isEmpty {
                            self?.managersCollection.backgroundView = self?.createBackground(labelText: .background(.noManagers))
                        }
                    }
            }
        }
    }

    @IBAction func doneDidPress(_ sender: Any) {
        dismiss(animated: true)
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
