import UIKit

class NewsViewController: UIViewController {
    
    @IBOutlet private(set) var newsTable: UITableView!
    
    private var user: UserProxy!
    
    let cellIdentifier = CellIdentifiers.NewsCell
    
    private var news: [News] = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        news = Test.CreateNews()
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NewsTableViewCell
        cell.configure(with: news[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.count
    }
}

extension NewsViewController: UITableViewDelegate {
    
}

//MARK: - WithUserInfo
extension NewsViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}
