import Foundation
import UIKit

enum ServicesControllers: String {
    case ServiceMaintenanceViewController = "1"
    case RepairngViewController = "2"
    case TestDriveViewController = "3"
    case HelpOnRoadViewController = "4"
}

enum AddInfoType {
    case first
    case next
}

public struct AppStoryboards {
    static let launchScreen = "LaunchScreen"
    static let auth = "Authentification"
    static let register = "FirstLaunchRegistration"
    static let main = "MainMenu"
}

public struct AppViewControllers {
    static let mainMenuTabBarController = "MainMenuTabBarController"
    static let authNavigation = "AuthNavigationController"
    static let registerNavigation = "RegisterNavigationController"
    
    static let personalInfoViewController = "PersonalInfoViewController"
    static let dealerViewController = "DealerViewController"
    static let addingCarViewController = "AddingCarViewController"
    static let checkVinViewController = "CheckVinViewController"
    
    static let auth = "AuthViewController"
    static let mainMenu = "MainMenuViewController"
    static let offers = "OffersViewController"
    static let services = "ServicesViewController"
    static let myCar = "MyCarViewController"
    
    static let constructor = "ConstructorViewController"
    
    struct ServicesMap {
        static let map: [ServicesControllers:UIViewController.Type] =
            [.TestDriveViewController:TestDriveViewController.self,
             .ServiceMaintenanceViewController:ServiceMaintenanceViewController.self,
             .RepairngViewController:RepairingViewController.self,
             .HelpOnRoadViewController:HelpOnRoadViewController.self]
    }
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
}
