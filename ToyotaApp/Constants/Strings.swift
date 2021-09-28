import Foundation

#warning("todo: make .strings file")
extension String {
    static func common(_ string: CommonStrings) -> String {
        string.rawValue
    }
    
    static func background(_ string: BackgroundString) -> String {
        string.rawValue
    }
    
    static func error(_ string: AppErrors) -> String {
        string.rawValue
    }
    
    enum CommonStrings: String {
        case save = "Сохранить"
        case success = "Успех"
        case cancel = "Отмена"
        case ok = "Ок"
        case error = "Ошибка"
        case warning = "Предупреждение"
        case edit = "Редактировать"
        case yes = "Да"
        case no = "Нет"
        case choose = "Выбрать"
        case services = "Услуги"
        case book = "Оставить заявку"
        case confirmation = "Подтверждение"
        case changeNumberQuestion = "Вы действительно хотите изменить номер телефона?"
        case chooseShowroom = "Выберите салон"
        case enterNewNumber = "Введите новый номер"
        case pullToRefresh = "Потяните вниз для обновления"
        case retryRefresh = "потяните вниз для повторной загрузки."
        case personalDataSaved = "Личная информация успешно обновлена"
        case bookingSuccess = "Заявка оставлена и будет обработана в ближайшее время"
        case autoLinked = "Автомобиль успешно привязан к профилю"
        case phoneChanged = "Телефон упешно изменен"
    }
    
    enum BackgroundString: String {
        case noBookings = "На данный момент нет ни одного обращения."
        case noManagers = "На данный момент к Вам не привязано ни одного менеджера"
        case noCars = "Здесь будут отображаться Ваши автомобили. Как только Вы их добавите."
        case noServices = "Для данного автомобиля пока нет доступных сервисов. Не волнуйтесь, они скоро появятся."
        case addAutoToUnlock = "Добавьте автомобиль для разблокировки функций"
        case somethingWentWrong = "Что то пошло не так..."
    }
}

#warning("Deprecated")
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
    static let profileLoadError = "При загрузке профиля возникла ошибка, повторите регистрацию для корректного внесения и сохранения данных"
    static let managersLoadError = "Ошибка при загрузке списка менеджеров"
    static let noManagersBackground = "На данный момент к Вам не привязано ни одного менеджера"
}
