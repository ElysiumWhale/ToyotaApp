import UIKit

final class StatusView: UIView {
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
        case .cancelled:
            return (.systemRed, .common(.bookingCancelled))
        case .done:
            return (.systemGreen, .common(.bookingComplete))
        }
    }
}
