import Foundation

enum BookingStatus: String, Codable {
    case future = "0"
    case cancelled = "1"
    case done = "2"
}
