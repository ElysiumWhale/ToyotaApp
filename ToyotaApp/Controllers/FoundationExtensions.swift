import Foundation
import UIKit

//MARK: - Formatting hours and minutes
extension DateComponents {
    ///Format components in format **"hh:mm"** *(example: 12:01)*
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

//MARK: - Server & Client Formatters
extension DateFormatter {
    ///Formats date in **"yyyy-MM-dd"**
    static var ServerDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    ///Formats date in **"26 янв. 2077"**
    static var ClientDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateStyle = .medium
        return formatter
    }
}
