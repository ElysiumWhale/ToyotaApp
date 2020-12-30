import UIKit

class OffersViewController: UIViewController {
    
    private var userInfo: UserInfo?
    
    let cellIdentrifier = CellIdentifiers.NewsCell
    
    @IBOutlet private(set) var news: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension OffersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentrifier, for: indexPath)
    }
}

//MARK: - WithUserInfo
extension OffersViewController: WithUserInfo {
    func setUser(info: UserInfo) {
        userInfo = info
    }
}
