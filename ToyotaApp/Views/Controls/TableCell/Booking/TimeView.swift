import UIKit

final class TimeView: BaseView {
    private let timeLabel = UILabel()
    private let timeImage = UIImageView()

    override func addViews() {
        addSubviews(timeImage, timeLabel)
    }

    override func configureLayout() {
        timeImage.leadingToSuperview(offset: 5)
        timeLabel.trailingToSuperview(offset: 5)
        timeImage.trailingToLeading(of: timeLabel, offset: -5)
        timeLabel.topToSuperview()
        timeLabel.bottomToSuperview(offset: -2)
        timeImage.verticalToSuperview()
    }

    override func configureAppearance() {
        layer.cornerRadius = 5
        backgroundColor = .systemGroupedBackground

        timeLabel.textColor = .appTint(.signatureGray)
        timeLabel.font = .toyotaType(.regular, of: 16)
    }

    func configure(with booking: Booking) {
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
