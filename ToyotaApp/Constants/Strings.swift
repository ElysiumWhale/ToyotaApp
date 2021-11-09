import Foundation

#warning("todo: make .strings file")
extension String {
    static let empty = ""
    static let space = " "

    static func common(_ string: CommonStrings) -> String {
        string.rawValue
    }

    static func question(_ string: QuestionStrings) -> String {
        string.rawValue
    }

    static func background(_ string: BackgroundStrings) -> String {
        string.rawValue
    }

    static func error(_ string: AppErrors) -> String {
        string.rawValue
    }

    enum CommonStrings: String {
        /// Загрузка
        case loading = "Загрузка"
        /// Сохранить
        case save = "Сохранить"
        /// Успех
        case success = "Успех"
        /// Отмена
        case cancel = "Отмена"
        /// Ок
        case ok = "Ок"
        /// Ошибка
        case error = "Ошибка"
        /// Предупреждение
        case warning = "Предупреждение"
        /// Редактировать
        case edit = "Редактировать"
        /// Да
        case yes = "Да"
        /// Нет
        case no = "Нет"
        /// Выбрать
        case choose = "Выбрать"
        /// Услуга
        case service = "Услуга"
        /// Услуги
        case services = "Услуги"
        /// Машина
        case car = "Машина"
        /// Салон
        case showroom = "Салон"
        /// Город
        case city = "Город"
        /// Оставить заявку
        case book = "Оставить заявку"
        /// Подтверждение
        case confirmation = "Подтверждение"
        /// Подтверждние действия
        case actionConfirmation = "Подтверждение действия"
        /// Выберите салон
        case chooseShowroom = "Выберите салон"
        /// Выберите город
        case chooseCity = "Выберите город"
        /// Выберите машину
        case chooseCar = "Выберите машину"
        /// Выберите время
        case chooseTime = "Выберите время"
        /// Выберите услугу
        case chooseService = "Выберите услугу"
        /// Выберите дату и время
        case chooseDateTime = "Выберите дату и время"
        /// Укажите местоположение
        case enterLocation = "Укажите местоположение"
        /// Введите новый номер
        case enterNewNumber = "Введите новый номер"
        /// Потяните вниз для обновления
        case pullToRefresh = "Потяните вниз для обновления"
        /// потяните вниз для повторной загрузки.
        case retryRefresh = "потяните вниз для повторной загрузки."
        /// Личная информация успешно обновлена
        case personalDataSaved = "Личная информация успешно обновлена"
        /// Заявка оставлена и будет обработана в ближайшее время
        case bookingSuccess = "Заявка оставлена и будет обработана в ближайшее время"
        /// Автомобиль успешно привязан к профилю
        case autoLinked = "Автомобиль успешно привязан к профилю"
        /// Телефон упешно изменен
        case phoneChanged = "Телефон упешно изменен"
        
    }

    enum QuestionStrings: String {
        /// Вы действительно хотите выйти?
        case quit = "Вы действительно хотите выйти?"
        /// Вы действительно хотите отвязать от аккаунта машину?
        case removeCar = "Вы действительно хотите отвязать от аккаунта машину?"
        /// Вы действительно хотите изменить номер телефона?
        case changeNumber = "Вы действительно хотите изменить номер телефона?"
    }

    enum BackgroundStrings: String {
        /// На данный момент нет ни одного обращения.
        case noBookings = "На данный момент нет ни одного обращения."
        /// На данный момент к Вам не привязано ни одного менеджера.
        case noManagers = "На данный момент к Вам не привязано ни одного менеджера."
        /// Здесь будут отображаться Ваши автомобили. Как только Вы их добавите.
        case noCars = "Здесь будут отображаться Ваши автомобили. Как только Вы их добавите."
        /// Для данного автомобиля пока нет доступных сервисов. Не волнуйтесь, они скоро появятся.
        case noServices = "Для данного автомобиля пока нет доступных сервисов. Не волнуйтесь, они скоро появятся."
        /// Добавьте автомобиль для разблокировки функций
        case addAutoToUnlock = "Добавьте автомобиль для разблокировки функций."
        /// Что то пошло не так...
        case somethingWentWrong = "Что то пошло не так..."
        /// На данный момент нет актуальных предложений.
        case noNews = "На данный момент нет актуальных предложений."
    }
}

// MARK: - DateFormatting
extension String {
    static let ddMMyyyy = "dd.MM.yyyy"
    static let MMddyyyy = "MM.dd.yyyy"
    static let yyyyMMdd = "yyyy-MM-dd"
}

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
