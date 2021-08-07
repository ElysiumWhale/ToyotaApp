import Foundation

enum NetworkErrors: String, Error {
    case corruptedData = "-100"
    case lostConnection = "-101"
    case responseTimeout = "-102"
}

enum AppErrors: String, Error {
    case keyValueDoesNotExist
    case wrongKeyForValue
    case notFullProfile
    case unknownError = "Произошла непредвиденная ошибка, повторите действие"
    case requestError = "Ошибка при запросе данных"
    case serverBadResponse = "Сервер прислал неверные данные"
    case connectionLost = "Потеряно соедниние с интернетом, проверьте подключение"
}
