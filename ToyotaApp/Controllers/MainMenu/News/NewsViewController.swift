import UIKit

class NewsViewController: UIViewController {
    
    @IBOutlet private(set) var newsTable: UITableView!
    
    private var userInfo: UserInfo!
    
    let cellIdentifier = CellIdentifiers.NewsCell
    
    private var news: [News] = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #warning("TEST NEWS")
        let url = URL(string: "https://www.vhv.rs/dpng/d/522-5221969_toyota-logo-symbol-vector-vector-toyota-logo-png.png")!
        if let showroom = userInfo.showrooms.array.first {
            news.append(News(title: "Функционал в разработке", content: "Скоро здесь появятся различные новости от дилеров и специальные предложения!", date: Date(), showroomId: showroom.id, showroomName: showroom.showroomName, imgUrl: url))
        } else {
            news.append(News(title: "Функционал в разработке", content: "Скоро здесь появятся различные новости от дилеров и специальные предложения!", date: Date(), showroomId: "", showroomName: "Тойота Самар", imgUrl: url))
        }
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
    func setUser(info: UserInfo) {
        userInfo = info
    }
}
