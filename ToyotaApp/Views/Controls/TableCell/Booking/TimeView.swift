import UIKit

final class TimeView: UIView {
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
        case .cancelled:
            return (.timeDone, .systemGray)
        case .done:
            return (.timeDone, .systemGreen)
        }
    }
}
