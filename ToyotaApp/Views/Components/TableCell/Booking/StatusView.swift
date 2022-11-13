import UIKit

final class StatusView: BaseView {
    private let statusLabel = UILabel()
    private let statusImage = UIImageView()

    override func addViews() {
        addSubviews(statusLabel, statusImage)
    }

    override func configureLayout() {
        statusImage.leadingToSuperview(offset: 5)
        statusLabel.trailingToSuperview(offset: 5)
        statusImage.trailingToLeading(of: statusLabel, offset: -5)
        statusLabel.topToSuperview()
        statusLabel.bottomToSuperview(offset: -2)
        statusImage.verticalToSuperview()
    }

    override func configureAppearance() {
        layer.cornerRadius = 5
        backgroundColor = .systemGroupedBackground

        statusLabel.font = .toyotaType(.book, of: 14)
        statusLabel.textColor = .appTint(.signatureGray)
        statusImage.image = .statusCircle
    }

    func configure(with booking: Booking) {
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
        case .cancelled:
            return (.systemRed, .common(.bookingCancelled))
        case .done:
            return (.systemGreen, .common(.bookingComplete))
        }
    }
}
