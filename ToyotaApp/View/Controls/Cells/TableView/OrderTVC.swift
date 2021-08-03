import UIKit

class OrderCell: UITableViewCell {
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var contentLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var carLabel: UILabel!
    
    func configure(with service: Service) {
        configureAsMock()
    }
}

// MARK: - Mock
extension OrderCell {
    func configureAsMock() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd.yyyy"
        let dateString = dateFormatter.string(from: Date())
        dateLabel.text = dateString
        carLabel.text = "RAV4"
        contentLabel.text = "Произведен успешный вызов эвакуатора"
        titleLabel.text = "Оказание услуги"
    }
}
