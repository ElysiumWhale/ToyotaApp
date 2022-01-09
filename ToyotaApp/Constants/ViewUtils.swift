import UIKit

/// **Warning!** Equality comparison will result `false` **ONLY** if one operator is `.register` and another is `.changeNumber`.
/// In **rest** cases it will return `true`.
enum AuthType: Equatable {
    case register
    case changeNumber(with: Notificator)

    static func == (lhs: AuthType, rhs: AuthType) -> Bool {
        if case register = lhs, case register = rhs {
            return true
        }
        if case changeNumber = lhs, case changeNumber = rhs {
            return true
        }
        return false
    }
}

/// **Warning!** Equality comparison will result `false` **ONLY** if one operator is `.register` and another is `.update`.
/// In **rest** cases it will return `true`.
enum AddInfoType: Equatable {
    case register
    case update(with: UserProxy)

    static func == (lhs: AddInfoType, rhs: AddInfoType) -> Bool {
        if case register = lhs, case register = rhs {
            return true
        }
        if case update = lhs, case update = rhs {
            return true
        }
        return false
    }
}

// MARK: - Structs with view constants
public enum AppStoryboards: String {
    /// LaunchScreen
    case launchScreen = "LaunchScreen"
    /// Main
    case main = "Main"
    /// Authentification
    case auth = "Authentification"
    /// FirstLaunchRegistration
    case register = "FirstLaunchRegistration"
    /// MainMenu
    case mainMenu = "MainMenu"
}

enum ViewControllers: String {
    /// MainMenuTabBarController
    case mainMenuTabBar = "MainMenuTabBarController"
    /// AuthNavigationController
    case authNavigation = "AuthNavigationController"
    /// RegisterNavigationController
    case registerNavigation = "RegisterNavigationController"
    /// PersonalInfoViewController
    case personalInfo = "PersonalInfoViewController"
    /// DealerViewController
    case dealer = "DealerViewController"
    /// AddingCarViewController
    case addCar = "AddCarViewController"
    /// CheckVinViewController
    case checkVin = "CheckVinViewController"
    /// ConnectionLostViewController
    case connectionLost = "ConnectionLostViewController"
    /// AuthViewController
    case auth = "AuthViewController"
    /// MainMenuViewController
    case mainMenu = "MainMenuViewController"
    /// OffersViewController
    case offers = "OffersViewController"
    /// ServicesViewController
    case services = "ServicesViewController"
    /// MyCarViewController
    case myCar = "MyCarViewController"
    /// AgreementViewController
    case agreement = "AgreementViewController"
    /// CityPickerViewController
    case cityPick = "CityPickerViewController"
}

public enum SegueIdentifiers: String {
    // MARK: - Auth

    /// NumberToCodeSegue
    case numberToCode = "NumberToCodeSegue"

    // MARK: - Reg

    /// PersonInfoToDealer
    case personInfoToDealer = "PersonInfoToDealer"
    /// PersonInfoToCity
    case personInfoToCity = "PersonInfoToCity"
    /// CityToAddCar
    case cityToAddCar = "CityToAddCar"
    /// AddCarToEndRegistration
    case addCarToEndRegistration = "AddCarToEndRegistration"
    /// DealerToCar
    case dealerToCar = "DealerToCar"
    /// DealerToCheckVin
    case dealerToCheckVin = "DealerToCheckVin"
    /// CarToEndRegistration
    case carToEndRegistration = "CarToEndRegistration"
    /// CarToCheckVin
    case carToCheckVin = "CarToCheckVin"

    // MARK: - Services

    /// ServiceNavToTech
    case serviceNavToTech = "ServiceNavToTech"
    /// ServiceNavToService
    case serviceNavToService = "ServiceNavToService"
    /// ServiceNavToTest
    case serviceNavToTest = "ServiceNavToTest"
    /// ServiceNavToEmerg
    case serviceNavToEmerg = "ServiceNavToEmerg"
    /// ServiceNavToFeedback
    case serviceNavToFeedback = "ServiceNavToFeedback"

    // MARK: - MyProfile

    /// MyProfileToCars
    case myProfileToCars = "MyProfileToCars"
    /// MyProfileToSettings
    case myProfileToSettings = "MyProfileToSettings"
    /// MyProfileToManagers
    case myManagersSegueCode = "MyProfileToManagers"
    /// MyProfileToBookings
    case myProfileToBookings = "MyProfileToBookings"
}

public struct CellIdentifiers {
    static let CarCell = "CarCell"
    static let NewsCell = "NewsCell"
    static let ServiceCell = "ServiceCell"
    static let BookingCell = "BookingCell"
    static let ManagerCell = "ManagerCell"
}

public struct TimeMap {
    static func getFullSchedule(after hour: Int? = nil) -> [DateComponents] {
        var times: [DateComponents] = []
        for key in 18...38 {
            if let now = hour, clientMap[key]!.hour ?? -1 < now + 1 {
                continue
            }
            times.append(clientMap[key]!)
        }
        return times
    }

    static let clientMap: [Int: DateComponents] = [
        14: .init(hour: 07, minute: 00), 15: .init(hour: 07, minute: 30),
        16: .init(hour: 08, minute: 00), 17: .init(hour: 08, minute: 30),
        18: .init(hour: 09, minute: 00), 19: .init(hour: 09, minute: 30),
        20: .init(hour: 10, minute: 00), 21: .init(hour: 10, minute: 30),
        22: .init(hour: 11, minute: 00), 23: .init(hour: 11, minute: 30),
        24: .init(hour: 12, minute: 00), 25: .init(hour: 12, minute: 30),
        26: .init(hour: 13, minute: 00), 27: .init(hour: 13, minute: 30),
        28: .init(hour: 14, minute: 00), 29: .init(hour: 14, minute: 30),
        30: .init(hour: 15, minute: 00), 31: .init(hour: 15, minute: 30),
        32: .init(hour: 16, minute: 00), 33: .init(hour: 16, minute: 30),
        34: .init(hour: 17, minute: 00), 35: .init(hour: 17, minute: 30),
        36: .init(hour: 18, minute: 00), 37: .init(hour: 18, minute: 30),
        38: .init(hour: 19, minute: 00), 39: .init(hour: 19, minute: 30),
        40: .init(hour: 20, minute: 00), 41: .init(hour: 20, minute: 30)
    ]

    static let serverMap: [String: Int] = [
        "00:00": 0, "00:30": 1,
        "1:00": 2, "1:30": 3,
        "2:00": 4, "2:30": 5,
        "3:00": 6, "3:30": 7,
        "4:00": 8, "4:30": 9,
        "5:00": 10, "5:30": 11,
        "6:00": 12, "6:30": 13,
        "7:00": 14, "7:30": 15,
        "8:00": 16, "8:30": 17,
        "9:00": 18, "9:30": 19,
        "10:00": 20, "10:30": 21,
        "11:00": 22, "11:30": 23,
        "12:00": 24, "12:30": 25,
        "13:00": 26, "13:30": 27,
        "14:00": 28, "14:30": 29,
        "15:00": 30, "15:30": 31,
        "16:00": 32, "16:30": 33,
        "17:00": 34, "17:30": 35,
        "18:00": 36, "18:30": 37,
        "19:00": 38, "19:30": 39,
        "20:00": 40, "20:30": 41,
        "21:00": 42, "21:30": 43,
        "22:00": 44, "22:30": 45,
        "23:00": 46, "23:30": 47
    ]
}
