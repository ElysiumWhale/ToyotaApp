import Foundation
import UIKit

//MARK: - Enums for VC logic
enum ServicesControllers: String {
    case ServiceMaintenanceViewController = "6" //1
    case RepairngViewController = "5" //2
    case TestDriveViewController = "8" //3
    case HelpOnRoadViewController = "2" //4
}

///**Warning!** Equality comprasion will result `false` **ONLY** if one operator is `.register` and another is `.changeNumber`.
/// In **rest** cases it will return `true`.
enum AuthType: Equatable {
    case register
    case changeNumber(with: Notificator)
    
    static func == (lhs: AuthType, rhs: AuthType) -> Bool {
        if case register = lhs, case register = rhs {
            return true
        }
        if case changeNumber(_) = lhs, case changeNumber(_) = rhs {
            return true
        }
        return false
    }
}

///**Warning!** Equality comprasion will result `false` **ONLY** if one operator is `.register` and another is `.update`.
/// In **rest** cases it will return `true`.
enum AddInfoType: Equatable {
    case register
    case update(with: UserProxy)
    
    static func == (lhs: AddInfoType, rhs: AddInfoType) -> Bool {
        if case register = lhs, case register = rhs {
            return true
        }
        if case update(_) = lhs, case update(_) = rhs {
            return true
        }
        return false
    }
}

//MARK: - Structs with view constants
public struct AppStoryboards {
    static let launchScreen = "LaunchScreen"
    static let main = "Main"
    static let auth = "Authentification"
    static let register = "FirstLaunchRegistration"
    static let mainMenu = "MainMenu"
}

public struct AppViewControllers {
    static let mainMenuTabBar = "MainMenuTabBarController"
    static let authNavigation = "AuthNavigationController"
    static let registerNavigation = "RegisterNavigationController"
    
    static let personalInfo = "PersonalInfoViewController"
    static let dealer = "DealerViewController"
    static let addingCar = "AddingCarViewController"
    static let checkVin = "CheckVinViewController"
    
    static let connectionLost = "ConnectionLostViewController"
    static let auth = "AuthViewController"
    static let mainMenu = "MainMenuViewController"
    static let offers = "OffersViewController"
    static let services = "ServicesViewController"
    static let myCar = "MyCarViewController"
    
    static let constructor = "ConstructorViewController"
    
    struct ServicesMapOld {
        static let map: [ServicesControllers:UIViewController.Type] =
            [.TestDriveViewController:TestDriveViewController.self,
             .HelpOnRoadViewController:HelpOnRoadViewController.self]
    }
    
//    struct ServicesMap {
//        static let map: [String:UIViewController.Type] =
//            ["1":BaseServiceViewController.self,
//             "2":TwoPicksServiceController.self,
//             "3":ThreePicksServiceController.self]
//    }
}

public struct SegueIdentifiers {
    //Auth
    static let NumberToCode = "NumberToCodeSegue"
    //Reg
    static let PersonInfoToDealer = "PersonInfoToDealer"
    static let DealerToCar = "DealerToCar"
    static let DealerToCheckVin = "DealerToCheckVin"
    static let CarToEndRegistration = "CarToEndRegistration"
    static let CarToCheckVin = "CarToCheckVin"
    //Services
    static let ServiceNavToTech = "ServiceNavToTech"
    static let ServiceNavToService = "ServiceNavToService"
    static let ServiceNavToTest = "ServiceNavToTest"
    static let ServiceNavToEmerg = "ServiceNavToEmerg"
    static let ServiceNavToFeedback = "ServiceNavToFeedback"
    //MyProfile
    static let MyProfileToCars = "MyProfileToCars"
    static let MyProfileToSettings = "MyProfileToSettings"
}

public struct CellIdentifiers {
    static let CarCell = "CarCell"
    static let NewsCell = "NewsCell"
    static let ServiceCell = "ServiceCell"
    static let OrderCell = "OrderCell"
}

#warning("todo: make .strings file")
public struct CommonText {
    static let save = "Сохранить"
    static let success = "Успех"
    static let cancel = "Отмена"
    static let ok = "Ок"
    static let error = "Ошибка"
    static let edit = "Редактировать"
    static let yes = "Да"
    static let no = "Нет"
    static let choose = "Выбрать"
    static let pullToRefresh = "Потяните вниз для обновления"
    static let noServices = "Для данного автомобиля пока нет доступных сервисов. Не волнуйтесь, они скоро появятся."
    static let networkError = "Ошибка сети, проверьте подключение"
    static let retryRefresh = "потяните вниз для повторной загрузки."
    static let servicesError = "Ошибка при загрузке услуг"
}

public struct TimeMap {
    static let map: [Int:DateComponents] = [
        18:.init(hour: 9, minute: 00),
        19:.init(hour: 9, minute: 30),
        20:.init(hour: 10, minute: 00),
        21:.init(hour: 10, minute: 30),
        22:.init(hour: 11, minute: 00),
        23:.init(hour: 11, minute: 30),
        24:.init(hour: 12, minute: 00),
        25:.init(hour: 12, minute: 30),
        26:.init(hour: 13, minute: 00),
        27:.init(hour: 13, minute: 30),
        28:.init(hour: 14, minute: 00),
        29:.init(hour: 14, minute: 30),
        30:.init(hour: 15, minute: 00),
        31:.init(hour: 15, minute: 30),
        32:.init(hour: 16, minute: 00),
        33:.init(hour: 16, minute: 30),
        34:.init(hour: 17, minute: 00),
        35:.init(hour: 17, minute: 30),
        36:.init(hour: 18, minute: 00),
        37:.init(hour: 18, minute: 30),
        38:.init(hour: 19, minute: 00)
    ]
    
    static func getFullSchedule() -> [DateComponents] {
        var times: [DateComponents] = []
        for key in 18...38 {
            times.append(map[key]!)
        }
        return times
    }
}
