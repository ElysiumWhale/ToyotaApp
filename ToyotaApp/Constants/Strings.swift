import Foundation

extension String {
    static let empty = ""
    static let space = " "
    static let newString = "\n"

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
        /// Далее
        case next = "Далее"
        /// Сохранить
        case save = "Сохранить"
        /// Успех
        case success = "Успех"
        /// Отмена
        case cancel = "Отмена"
        /// Готово
        case done = "Готово"
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
        /// Изменить
        case change = "Изменить"
        /// Услуга
        case service = "Услуга"
        /// Услуги
        case services = "Услуги"
        /// Акции
        case offers = "Акции"
        /// Профиль
        case profile = "Профиль"
        /// Машина
        case car = "Машина"
        /// Автомобиль
        case auto = "Автомобиль"
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
        /// Нет автомобилей
        case noCars = "Нет автомобилей"
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
        /// Загрузка салонов
        case showroomsLoading = "Загрузка салонов"
        /// Нет доступных салонов
        case noShoworooms = "Нет доступных салонов"
        /// Не исполнено
        case bookingCancelled = "Не исполнено"
        /// Предстоит
        case bookingInFuture = "Предстоит"
        /// Исполнено
        case bookingComplete = "Исполнено"
        /// Настройки
        case settings = "Настройки"
        /// Номер телефона
        case phoneNumber = "Номер телефона"
        /// ALYANS PRO, OOO
        case alyansPro = "ALYANS PRO, OOO"
        /// Условия соглашения
        case terms = "Условия соглашения"
        /// Вход в личный кабинет:
        case accountEntering = "Вход в личный кабинет:"
        /// Регистрируясь, Вы принимаете
        case acceptWhileRegister = "Регистрируясь, Вы принимаете"
        /// Ввод телефона
        case phoneEntering = "Ввод телефона"
        /// Код из смс
        case codeFromSms = "Код из смс"
        /// Введите код из СМС для
        case enterCodeFromSmsFor = "Введите код из СМС для"
        /// Повторить
        case retry = "Повторить"
        /// Введите сообщение
        case enterMessage = "Введите сообщение"
        /// Здесь будут отображаться введенные сообщения...
        case thereWillBeMessages = "Здесь будут отображаться введенные сообщения..."
        /// Поддержка
        case support = "Поддержка"
        /// Имя
        case name = "Имя"
        /// Отчество
        case secondName = "Отчество"
        /// Фамилия
        case lastName = "Фамилия"
        /// Дата рождения
        case birthDate = "Дата рождения"
        /// Электронная почта
        case email = "Электронная почта"
        /// Заполните информацию о себе
        case fillPersonalInfo = "Заполните информацию о себе"
        /// Данные
        case data = "Данные"
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
        /// Для данного салона пока нет доступных сервисов. Не волнуйтесь, они скоро появятся.
        case noServices = "Для данного салона пока нет доступных сервисов. Не волнуйтесь, они скоро появятся."
        /// Добавьте автомобиль для разблокировки функций
        case addAutoToUnlock = "Добавьте автомобиль для разблокировки функций."
        /// Что то пошло не так...
        case somethingWentWrong = "Что то пошло не так..."
        /// На данный момент нет актуальных предложений.
        case noNews = "На данный момент нет актуальных предложений."
        /// Нет доступных городов.
        case noCities = "Нет доступных городов."
        /// Необходимо выбрать город и салон для обслуживания
        case noCityAndShowroom = "Необходимо выбрать город и салон для обслуживания."
    }
}

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
