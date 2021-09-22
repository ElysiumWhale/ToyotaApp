import Foundation
import UIKit

// MARK: - Formatting hours and minutes
extension DateComponents {
    /// Format components in format **"hh:mm"**
    ///
    /// Example: **18:01**
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

// MARK: - Init with request key
extension URLQueryItem {
    init(_ key: RequestKeys, _ value: String?) {
        self.init(name: key.rawValue, value: value)
    }
}

#warning("todo: make .strings file")
extension String {
    static let save = "Сохранить"
    static let success = "Успех"
    static let cancel = "Отмена"
    static let ok = "Ок"
    static let error = "Ошибка"
    static let warning = "Предупреждение"
    static let edit = "Редактировать"
    static let yes = "Да"
    static let no = "Нет"
    static let choose = "Выбрать"
    static let pullToRefresh = "Потяните вниз для обновления"
    static let noServices = "Для данного автомобиля пока нет доступных сервисов. Не волнуйтесь, они скоро появятся."
    static let networkError = "Ошибка сети, проверьте подключение"
    static let retryRefresh = "потяните вниз для повторной загрузки."
    static let servicesError = "Ошибка при загрузке услуг"
    static let stillNoConnection = "Соединение с интернетом все еще отсутствует"
    static let errorWhileAuth = "При входе произошла ошибка, войдите повторно"
    static let noCarsBackground = "Здесь будут отображаться Ваши автомобили. Как только Вы их добавите."
    static let blockFunctionsAlert = "Увы, на данный момент Вам недоступен полный функционал приложения. Для разблокировки добавьте автомобиль."
    static let addAutoToUnlock = "Добавьте автомобиль для разблокировки функций"
}
