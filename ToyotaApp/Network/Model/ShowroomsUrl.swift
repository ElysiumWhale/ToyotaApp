import Foundation

enum ShowroomsUrl: String {
    case samaraAurora = "7"
    case samaraNorth = "2"
    case samraSouth = "1"

    var baseUrl: String {
        switch self {
            case .samaraAurora:
                return "https://cars.toyota-aurora.ru"
            case .samaraNorth:
                return "https://cars.toyotasever.ru"
            case .samraSouth:
                return "https://cars.toyotasamaraug.ru"
        }
    }

    var url: String {
        switch self {
            case .samaraAurora:
                return "https://cars.toyota-aurora.ru/special-offers-list"
            case .samaraNorth:
                return "https://cars.toyotasever.ru/special-offers-list"
            case .samraSouth:
                return "https://cars.toyotasamaraug.ru/special-offers-list"
        }
    }

    init?(rawValue: String?) {
        guard let rawValue = rawValue else {
            return nil
        }

        self.init(rawValue: rawValue)
    }
}
