import Foundation

typealias VoidParameterClosure<T> = (T) -> Void
typealias VoidClosure = () -> Void

// MARK: - Formatting hours and minutes
extension DateComponents {
    /// Format components in format **"hh:mm"**
    ///
    /// Example: **18:01**
    var hourAndMinute: String {
        var hourStr = "00"
        var minStr = "00"
        if let hour = hour {
            hourStr = "\(hour)"
        }
        if let min = minute, min != 0 {
            minStr = "\(min)"
        }
        return "\(hourStr):\(minStr)"
    }
}

// MARK: - Server & Client Formatters
enum DateFormatters {
    case server(_ date: Date)
    case client(_ date: Date)
    case common(_ date: Date)
    case display(_ date: Date)
    
    func string() -> String {
        switch self {
            case .server(let date):
                return DateFormatter.server.string(from: date)
            case .client(let date):
                return DateFormatter.client.string(from: date)
            case .common(let date):
                return DateFormatter.common.string(from: date)
            case .display(let date):
                return DateFormatter.display.string(from: date)
        }
    }
}

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
        formatter.dateFormat = .yyyyMMdd
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
        formatter.dateFormat = .MMddyyyy
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
        formatter.dateFormat = .ddMMyyyy
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }
}

// MARK: - Init with request key
extension URLQueryItem {
    init(_ key: RequestKeys, _ value: String?) {
        self.init(name: key.rawValue, value: value)
    }
}

// MARK: - Collection helpers
extension Collection {
    func any(_ condition: (Self.Element) -> Bool) -> Bool {
        first(where: condition) != nil
    }
}
