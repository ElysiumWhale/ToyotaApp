import UIKit

class BookingCell: UITableViewCell {
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var contentLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var carLabel: UILabel!
    @IBOutlet private var licenseLabel: UILabel!
    @IBOutlet private var carImage: UIImageView!
    
    func configure(with booking: Booking) {
        dateLabel.text = DateFormatter.display.string(from: DateFormatter.server.date(from: booking.date) ?? Date())
        carLabel.text = booking.carName
        contentLabel.text = booking.serviceName
        titleLabel.text = booking.showroomName
        licenseLabel.text = ""
        if !booking.licensePlate.isEmpty {
            licenseLabel.text = booking.licensePlate
        } else {
            carImage.isHidden = true
        }
    }
}

// MARK: - Mock
extension BookingCell {
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
