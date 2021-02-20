import UIKit

class OrderCell: UITableViewCell {
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var contentLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    
    func configure(with service: Service) {
        dateLabel.text = "21.05.1998"
        contentLabel.text = "Успешный вызов эвакуатора"
        titleLabel.text = "Вызов эвакуатора"
    }
}
