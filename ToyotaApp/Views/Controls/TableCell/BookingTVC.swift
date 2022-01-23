import UIKit

class BookingCell: TableCell {
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var contentLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var carLabel: UILabel!
    @IBOutlet private var licenseLabel: UILabel!
    @IBOutlet private var statusView: UIView!
    @IBOutlet private var statusImage: UIImageView!
    @IBOutlet private var statusLabel: UILabel!

    class var identifier: UITableView.TableCells { .bookingCell }

    func configure(with booking: Booking) {
        titleLabel.text = booking.showroomName
        contentLabel.text = booking.serviceName
        carLabel.text = booking.carName.isEmptyOrWithoutAuto ? .empty : booking.carName
        licenseLabel.text = booking.licensePlate.uppercased()
        dateLabel.text = DateFormatter.display.string(from: booking.date)
        configureStatusView(with: booking)
    }

    private func configureStatusView(with booking: Booking) {
        statusView.layer.cornerRadius = 5
        var bookingDate = booking.bookingDate
        let creationDate = booking.creationDate ?? Date()

        if let date = bookingDate {
            let key = Int(booking.startTime) ?? 14
            if key > 14 && key < 41 {
                bookingDate = Calendar.current.date(byAdding: TimeMap.clientMap[key]!, to: date)!
            }
        }

        let (color, text) = booking.status.getAppearance(for: bookingDate ?? creationDate)
        statusLabel.text = text
        statusImage.tintColor = color
    }
}

private extension String {
    var isEmptyOrWithoutAuto: Bool {
        self.isEmpty || self == "Без авто"
    }
}
