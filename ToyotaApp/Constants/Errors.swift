import Foundation

enum NetworkErrors: String, Error {
    case request = "-1"
    case corruptedData = "-100"
    case lostConnection = "-101"
    case responseTimeout = "-102"

    var message: String {
        switch self {
            case .request: return AppErrors.requestError.rawValue
            case .corruptedData: return AppErrors.serverBadResponse.rawValue
            case .lostConnection: return AppErrors.connectionLost.rawValue
            case .responseTimeout: return AppErrors.responseTimeout.rawValue
        }
    }
}

enum AppErrors: String, Error {
    case keyValueDoesNotExist
    case wrongKeyForValue
    case notFullProfile
    case unknownError = "Произошла непредвиденная ошибка, повторите действие"
    case requestError = "Ошибка при запросе данных"
    case serverBadResponse = "Сервер прислал неверные данные"
    case connectionLost = "Потеряно соедниние с интернетом, проверьте подключение"
    case responseTimeout = "Превышено время ожидания ответа"
    case networkError = "Ошибка сети, проверьте подключение"
    case servicesError = "Ошибка при загрузке услуг"
    case stillNoConnection = "Соединение с интернетом все еще отсутствует"
    case errorWhileAuth = "При входе произошла ошибка, войдите повторно"
    case blockFunctionsAlert = "Увы, на данный момент Вам недоступен полный функционал приложения. Для разблокировки добавьте автомобиль."
    case profileLoadError = "При загрузке профиля возникла ошибка, повторите регистрацию для корректного внесения и сохранения данных"
    case managersLoadError = "Ошибка при загрузке списка менеджеров"
    case citiesLoadError = "Ошибка при загрузке городов, повторите позднее"
    case savingError = "Произошла ошибка при сохранении данных, повторите попытку позже"
    case checkInput = "Неккоректные данные. Проверьте введенную информацию!"
    case vinCodeError = "Ошибка при проверке VIN-кода, проверьте правильность кода и попробуйте снова"
    case geoRestriction = "Для использования услуги необходимо предоставить доступ к геопозиции"
    case newsError = "При загрузке предложений произошла ошибка, проверьте подключение к интернету и повторите позже"
}

// MARK: - ErrorResponse
public struct ErrorResponse: Codable, Error {
    let code: String
    let message: String?

    var errorCode: NetworkErrors {
        return .init(rawValue: code) ?? .request
    }
    
    init(code: String, message: String?) {
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
