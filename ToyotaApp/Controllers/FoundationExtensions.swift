import Foundation
import UIKit

// MARK: - Formatting hours and minutes
extension DateComponents {
    ///Format components in format **"hh:mm"**
    ///
    ///Example: **18:01**
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

// MARK: - Server & Client Formatters
extension DateFormatter {
    /**
     Formats date in **yyyy-MM-dd**
     
     Example:
     ```
     "2020-12-25"
     ```
     */
    static var server: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }
    
    /**
     Formats date in **ru**  medium date style
     
     Example:
     ```
     "26 янв. 2077"
     ```
     */
    static var client: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateStyle = .medium
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }
    
    /**
     Formats date in **MM.dd.yyyy**
     
     Example:
     ```
     "12.25.2020"
     ```
     */
    static var common: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }
    
    /**
     Formats date in **dd.MM.yyyy**
     
     Example:
     ```
     "25.12.2020"
     ```
     */
    static var display: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }
}
