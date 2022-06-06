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
    func asDate(with formatter: DateFormatters) -> Date? {
        formatter.date(from: self)
    }

    func swapFormats(from sourceFormat: DateFormatters,
                     to destinationFormat: DateFormatters) -> String {
        destinationFormat.string(from: sourceFormat.date(from: self) ?? Date())
    }

    func dateString(for formatter: DateFormatters) -> String {
        formatter.string(from: formatter.date(from: self) ?? Date())
    }
}

extension Date {
    func asString(_ formatter: DateFormatters) -> String {
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

        let hour: Int = concreteTime?.hour ?? self.hour
        let minute: Int = concreteTime?.minute ?? self.minute

        return calendar.isDateInToday(self)
                && now.hour < hour
                && now.minute < minute
    }

    var calendar: Calendar {
        Calendar.current
    }
}

enum DateFormatters {
    case common
    case display
    case client
    case server
    case serverWithTime

    func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    func date(from string: String) -> Date? {
        formatter.date(from: string)
    }

    private var formatter: DateFormatter {
        switch self {
            case .common: return .common
            case .display: return .display
            case .client: return .client
            case .server: return .server
            case .serverWithTime: return .serverWithTime
        }
    }
}

// MARK: - Formatters instanses
extension DateFormatter {
    private static func formatter(with format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }

    /// Formats date in **yyyy-MM-dd**
    ///
    /// Example:
    /// ```
    /// "2020-12-25"
    /// ```
    static let server: DateFormatter = formatter(with: .yyyyMMdd)

    /// Formats date in **yyyy-MM-dd HH:mm:ss**
    ///
    /// Example:
    /// ```
    /// "2020-12-25 23:04:45"
    /// ```
    static let serverWithTime: DateFormatter = formatter(with: .yyyyMMddTime)

    /// Formats date in **MM.dd.yyyy**
    ///
    /// Example:
    /// ```
    /// "12.25.2020"
    /// ```
    static let common: DateFormatter = formatter(with: .MMddyyyy)

    /// Formats date in **dd.MM.yyyy**
    ///
    /// Example:
    /// ```
    /// "25.12.2020"
    /// ```
    static let display: DateFormatter = formatter(with: .ddMMyyyy)

    /// Formats date in **ru**  medium date style
    ///
    /// Example:
    /// ```
    /// "26 янв. 2077"
    /// ```
    static var client: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru")
        formatter.dateStyle = .medium
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }
}

// MARK: - Date formatting masks
extension String {
    /// *dd.MM.yyyy*
    static let ddMMyyyy = "dd.MM.yyyy"
    /// *MM.dd.yyyy*
    static let MMddyyyy = "MM.dd.yyyy"
    /// *yyyy-MM-dd*
    static let yyyyMMdd = "yyyy-MM-dd"
    /// *yyyy-MM-dd HH:mm:ss*
    static let yyyyMMddTime = "yyyy-MM-dd HH:mm:ss"
}
