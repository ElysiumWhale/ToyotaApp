import Foundation
import UIKit

extension DateComponents {
    func getHourAndMinute() -> String {
        var hourStr = "00"
        var minStr = "00"
        if let hour = self.hour {
            hourStr = "\(hour)"
        }
        if let min = self.minute, min != 0 {
            minStr = "\(min)"
        }
        return "\(hourStr):\(minStr)"
    }
}
