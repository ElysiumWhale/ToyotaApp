import Foundation
import UIKit

enum ServicesControllers: String {
    case ServiceMaintenanceViewController = "1"
    case RepairngViewController = "2"
    case TestDriveViewController = "3"
    case HelpOnRoadViewController = "4"
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
}

public struct CellIdentifiers {
    static let CarCell = "CarCell"
    static let NewsCell = "NewsCell"
    static let ServiceCell = "ServiceCell"
}
