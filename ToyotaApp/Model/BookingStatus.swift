import Foundation

enum BookingStatus: String, Codable {
    case future = "0"
    case cancelled = "1"
    case done = "2"

    func inFuture(date: Date) -> Bool {
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
