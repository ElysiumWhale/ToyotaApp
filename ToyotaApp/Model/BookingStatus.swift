import Foundation
import class UIKit.UIColor

enum BookingStatus: String, Codable {
    case future = "0"
    case cancelled = "1"
    case done = "2"

    func getAppearance(for date: Date) -> (UIColor, String) {
        switch self {
            case .future: return inFuture(date: date)
                ? (.systemYellow, .common(.bookingInFuture))
                : (.systemRed, .common(.bookingCancelled))
            case .cancelled: return (.systemRed, .common(.bookingCancelled))
            case .done: return (.systemGreen, .common(.bookingComplete))
        }
    }

    private func inFuture(date: Date) -> Bool {
        if date < calendar.startOfDay(for: Date()) {
            return calendar.component(.day, from: date) == calendar.component(.day, from: Date())
        }

        return true
    }

}

// MARK: - Calendar
extension BookingStatus {
    var calendar: Calendar {
        Calendar.current
    }
}
