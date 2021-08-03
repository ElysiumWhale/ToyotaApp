import UIKit

class OrdersHistoryViewController: UIViewController {
    @IBOutlet private var ordersList: UITableView!
    
    private let cellIdentifier = CellIdentifiers.OrderCell
    
    private var orders: [Service] = [Service]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orders.append(Test.createOrder())
    }
    
    @IBAction func doneDidPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource
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

// MARK: - UITableViewDelegate
extension OrdersHistoryViewController: UITableViewDelegate {
    
}
