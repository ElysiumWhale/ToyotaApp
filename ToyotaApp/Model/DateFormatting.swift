import Foundation

// MARK: - Formatting hours and minutes
extension DateComponents {
    /// Format components in format **"hh:mm"**
    ///
    /// Example: **18:01**
    var hourAndMinute: String {
        var hourStr = "00"
        var minStr = "00"
        if let hour = hour, hour != 0 {
            hourStr = hour > 9 ? "\(hour)" : "0\(hour)"
        }
        if let min = minute, min != 0 {
            minStr = min > 9 ? "\(min)" : "0\(min)"
        }
        return "\(hourStr):\(minStr)"
    }
}

// MARK: - Formatting helpers
extension String {
    func asDate(with formatter: DateFormatter) -> Date? {
        formatter.date(from: self)
    }
}

extension Date {
    func asString(_ formatter: DateFormatter) -> String {
        formatter.string(from: self)
    }

    var day: Int {
        calendar.component(.day, from: self)
    }

    var hour: Int {
        calendar.component(.hour, from: self)
    }

    var minute: Int {
        calendar.component(.minute, from: self)
    }

    func inFuture(concreteTime: DateComponents? = nil) -> Bool {
        let now = Date()
        guard self < now else {
            return true
        }

        let hour: Int = concreteTime?.hour ?? hour
        let minute: Int = concreteTime?.minute ?? minute

        guard calendar.isDateInToday(self) else {
            return false
        }

        if now.hour < hour {
            return true
        } else if now.hour == hour {
            return now.minute < minute
        } else {
            return false
        }
    }

    private var calendar: Calendar {
        Calendar.current
    }
}

// MARK: - Formatters presets
extension DateFormatter {
    private static func formatter(with format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }

    func withTimeZone(_ identifier: String) -> Self {
        timeZone = TimeZone(identifier: identifier)
        return self
    }

    /// Formats date in **yyyy-MM-dd**
    ///
    /// Example:
    /// ```
    /// "2020-12-25"
    /// ```
    static let server = formatter(with: .yyyyMMdd)

    /// Formats date in **yyyy-MM-dd HH:mm:ss**
    ///
    /// Example:
    /// ```
    /// "2020-12-25 23:04:45"
    /// ```
    static let serverWithTime = formatter(with: .yyyyMMddTime)

    /// Formats date in **dd.MM.yyyy**
    ///
    /// Example:
    /// ```
    /// "25.12.2020"
    /// ```
    static let display = formatter(with: .ddMMyyyy)

    /// Formats date in **ru**  medium date style
    ///
    /// Example:
    /// ```
    /// "26 янв. 2077 г."
    /// ```
    static let client: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateStyle = .medium
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }()
}

// MARK: - Date formatting masks
extension String {
    /// *dd.MM.yyyy*
    static let ddMMyyyy = "dd.MM.yyyy"
    /// *yyyy-MM-dd*
    static let yyyyMMdd = "yyyy-MM-dd"
    /// *yyyy-MM-dd HH:mm:ss*
    static let yyyyMMddTime = "yyyy-MM-dd HH:mm:ss"
}
