import Foundation

enum NetworkErrors: String, Error {
    case request = "-1"
    case corruptedData = "-100"
    case lostConnection = "-101"
    case responseTimeout = "-102"

    var message: String {
        switch self {
        case .request:
            return AppErrors.requestError.rawValue
        case .corruptedData:
            return AppErrors.serverBadResponse.rawValue
        case .lostConnection:
            return AppErrors.connectionLost.rawValue
        case .responseTimeout:
            return AppErrors.responseTimeout.rawValue
        }
    }
}

enum AppErrors: String, Error {
    case keyValueDoesNotExist
    case wrongKeyForValue
    case notFullProfile
    case noUserIdAndPhone
    /// Произошла непредвиденная ошибка, повторите действие
    case unknownError = "Произошла непредвиденная ошибка, повторите действие"
    /// Ошибка при запросе данных
    case requestError = "Ошибка при запросе данных"
    /// Сервер прислал неверные данные
    case serverBadResponse = "Сервер прислал неверные данные"
    /// Потеряно соедниние с интернетом, проверьте подключение
    case connectionLost = "Потеряно соедниние с интернетом, проверьте подключение"
    /// Превышено время ожидания ответа
    case responseTimeout = "Превышено время ожидания ответа"
    /// Ошибка сети, проверьте подключение
    case networkError = "Ошибка сети, проверьте подключение"
    /// Ошибка при загрузке услуг
    case servicesError = "Ошибка при загрузке услуг"
    /// Соединение с интернетом все еще отсутствует
    case stillNoConnection = "Соединение с интернетом все еще отсутствует"
    /// При входе произошла ошибка, войдите повторно
    case errorWhileAuth = "При входе произошла ошибка, войдите повторно"
    /// Увы, на данный момент Вам недоступен полный функционал приложения. Для разблокировки добавьте автомобиль.
    case blockFunctionsAlert = "Увы, на данный момент Вам недоступен полный функционал приложения. Для разблокировки добавьте автомобиль"
    /// При загрузке профиля возникла ошибка, повторите регистрацию для корректного внесения и сохранения данных
    case profileLoadError = "При загрузке профиля возникла ошибка, повторите регистрацию для корректного внесения и сохранения данных"
    /// Ошибка при загрузке списка менеджеров
    case managersLoadError = "Ошибка при загрузке списка менеджеров"
    /// Ошибка при загрузке городов, повторите позднее
    case citiesLoadError = "Ошибка при загрузке городов, повторите позднее"
    /// Произошла ошибка при сохранении данных, повторите попытку позже
    case savingError = "Произошла ошибка при сохранении данных, повторите попытку позже"
    /// Неккоректные данные. Проверьте введенную информацию!
    case checkInput = "Неккоректные данные. Проверьте введенную информацию!"
    /// Ошибка при проверке VIN-кода, проверьте правильность кода и попробуйте снова
    case vinCodeError = "Ошибка при проверке VIN-кода, проверьте правильность кода и попробуйте снова"
    /// Для использования услуги необходимо предоставить доступ к геопозиции
    case geoRestriction = "Для использования услуги необходимо предоставить доступ к геопозиции"
    /// При загрузке предложений произошла ошибка, проверьте подключение к интернету и повторите позже
    case newsError = "При загрузке предложений произошла ошибка, проверьте подключение к интернету и повторите позже"
    /// Произошла ошибка при загрузке городов. Повторите попытку позже
    case citiesError = "Произошла ошибка при загрузке городов. Повторите попытку позже"
    /// При загрузке салонов произошла ошибка. Повторите попытку позже
    case showroomsError = "При загрузке салонов произошла ошибка. Повторите попытку позже"
    /// Неккоректно введен номер!
    case wrongPhoneEntered = "Неккоректно введен номер!"
    /// Введен неверный код!
    case wrongCodeEntered = "Введен неверный код!"
}

// MARK: - ErrorResponse
struct ErrorResponse: Codable, Hashable, Error {
    let code: String
    let message: String?

    var errorCode: NetworkErrors {
        .init(rawValue: code) ?? .request
    }

    init(code: String, message: String? = nil) {
        self.code = code
        self.message = message
    }

    init(code: NetworkErrors, message: String? = nil) {
        self.code = code.rawValue
        self.message = message ?? code.message
    }

    private enum CodingKeys: String, CodingKey {
        case code = "error_code"
        case message = "error_message"
    }
}

extension ErrorResponse {
    static func requestError(_ message: String? = nil) -> ErrorResponse {
        .init(code: .request, message: message)
    }

    static let lostConnection = ErrorResponse(code: .lostConnection)

    static let corruptedData = ErrorResponse(code: .corruptedData)

    static let responseTimeout = ErrorResponse(code: .responseTimeout)
}
