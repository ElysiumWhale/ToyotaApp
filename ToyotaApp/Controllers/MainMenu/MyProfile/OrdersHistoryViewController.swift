import UIKit

class OrdersHistoryViewController: UIViewController {
    @IBOutlet private var ordersList: UITableView!
    
    private let cellIdentifier = CellIdentifiers.OrderCell
    
    private var orders: [Service] = [Service]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orders.append(.init(id: "1", showroomId: "1", serviceTypeId: "1", serviceName: "1", koeffTime: "1", multiply: "1"))
    }
    
}

extension OrdersHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderCell
        cell.configure(with: orders[indexPath.item])
        return cell
    }
}

extension OrdersHistoryViewController: UITableViewDelegate {
    
}
