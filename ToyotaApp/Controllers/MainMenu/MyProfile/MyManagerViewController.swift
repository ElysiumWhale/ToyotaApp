import UIKit

class MyManagerViewController: UIViewController, BackgroundText {
    @IBOutlet private var managersCollection: UICollectionView!
    
    private let cellIdentifier = CellIdentifiers.ManagerCell
    
    private var user: UserProxy!
    
    private var managers: [Manager] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkService.shared.makePostRequest(page: RequestPath.Profile.getManagers, params: [URLQueryItem(name: RequestKeys.Auth.userId, value: user.getId), URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.Toyota)], completion: completion)
        
        func completion(for response: Result<ManagersDidGetResponse, ErrorResponse>) {
            switch response {
                case .failure(let error):
                    displayError(with: error.message ?? "") { [weak self] in
                        self?.managersCollection.backgroundView = self?.createBackground(labelText: error.message ?? "Ошибка при загрузке списка менеджеров")
                    }
                case .success(let data):
                    managers = data.managers
                    DispatchQueue.main.async { [weak self] in
                        self?.managersCollection.reloadData()
                        if data.managers.isEmpty {
                            self?.managersCollection.backgroundView = self?.createBackground(labelText: "На данный момент к Вам не привязано ни одного менеджера")
                        }
                    }
            }
        }
    }
}

//MARK: - UICollectionViewDataSource
extension MyManagerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        managers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ManagerCollectionViewCell
        cell.configure(from: managers[indexPath.row])
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension MyManagerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: { cell.alpha = 1 })
    }
}

//MARK: - WithUserInfo
extension MyManagerViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}
