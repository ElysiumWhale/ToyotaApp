import UIKit

// MARK: - BookingCell
class BookingCell: TableCell {
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

// MARK: - StatusView
class StatusView: UIView {
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var statusImage: UIImageView!

    func configure(with booking: Booking) {
        layer.cornerRadius = 5
        var bookingDate = booking.bookingDate
        let creationDate = booking.creationDate ?? Date()

        if let date = bookingDate {
            let key = Int(booking.startTime) ?? 14
            if key > 14 && key < 41 {
                bookingDate = Calendar.current.date(byAdding: TimeMap.clientMap[key]!, to: date)!
            }
        }

        let (color, text) = statusAppearance(for: booking, date: bookingDate ?? creationDate)
        statusLabel.text = text
        statusImage.tintColor = color
    }

    private func statusAppearance(for booking: Booking, date: Date) -> (UIColor, String) {
        switch booking.status {
            case .future:
                return booking.date.inFuture(concreteTime: booking.bookingTime)
                    ? (.systemYellow, .common(.bookingInFuture))
                    : (.systemRed, .common(.bookingCancelled))
            case .cancelled: return (.systemRed, .common(.bookingCancelled))
            case .done: return (.systemGreen, .common(.bookingComplete))
        }
    }
}

// MARK: - TimeView
class TimeView: UIView {
    @IBOutlet private(set) var timeLabel: UILabel!
    @IBOutlet private(set) var timeImage: UIImageView!

    func configure(with booking: Booking) {
        layer.cornerRadius = 5
        if let text = booking.bookingTime?.hourAndMinute {
            timeLabel.text = text
            let (image, color) = timeAppearance(for: booking)
            timeImage.image = image
            timeImage.tintColor = color
        } else {
            isHidden = true
        }
    }

    private func timeAppearance(for booking: Booking) -> (UIImage, UIColor) {
        switch booking.status {
            case .future:
                return booking.date.inFuture(concreteTime: booking.bookingTime)
                    ? (.timeAlert, .systemRed)
                    : (.timeDone, .systemGray)
            case .cancelled: return (.timeDone, .systemGray)
            case .done: return (.timeDone, .systemGreen)
        }
    }
}

private extension String {
    var isEmptyOrWithoutAuto: Bool {
        self.isEmpty || self == "Без авто"
    }
}

private extension UIImage {
    static var timeDone: UIImage {
        UIImage(systemName: "clock.badge.checkmark.fill")!
    }

    static var timeAlert: UIImage {
        UIImage(systemName: "clock.badge.exclamationmark.fill")!
    }
}
