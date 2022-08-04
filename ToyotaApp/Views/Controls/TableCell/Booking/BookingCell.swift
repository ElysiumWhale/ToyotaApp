import UIKit

// MARK: - BookingCell
final class BookingCell: TableCell {
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var contentLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var carLabel: UILabel!
    @IBOutlet private var licenseLabel: UILabel!
    @IBOutlet private var statusView: StatusView!
    @IBOutlet private var timeView: TimeView!

    class var identifier: UITableView.TableCells { .bookingCell }

    func configure(with booking: Booking) {
        titleLabel.text = booking.showroomName
        contentLabel.text = booking.serviceName
        carLabel.text = booking.carName.isEmptyOrWithoutAuto ? .empty : booking.carName
        licenseLabel.text = booking.licensePlate.uppercased()
        dateLabel.text = booking.date.asString(.display)
        statusView.configure(with: booking)
        timeView.configure(with: booking)
    }
}

private extension String {
    var isEmptyOrWithoutAuto: Bool {
        self.isEmpty || self == "Без авто"
    }
}
