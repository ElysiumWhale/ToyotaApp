import Foundation

public struct AppStoryboards {
    static let launchScreen = "LaunchScreen"
    static let auth = "Authentification"
    static let register = "FirstLaunchRegistration"
    static let main = "Main"
}

public struct AppViewControllers {
    static let mainMenuTabBarController = "MainMenuTabBarController"
    static let authNavigation = "AuthNavigationController"
    static let registerNavigation = "RegisterNavigationController"
    
    static let personalInfoViewController = "PersonalInfoViewController"
    static let dealerViewController = "DealerViewController"
    static let addingCarViewController = "AddingCarViewController"
    
    static let auth = "AuthViewController"
    static let mainMenu = "MainMenuViewController"
    static let offers = "OffersViewController"
    static let services = "ServicesViewController"
    static let myCar = "MyCarViewController"
}

public struct SegueIdentifiers {
    static let NumberToCode = "NumberToCodeSegue"
    static let PersonInfoToDealer = "PersonInfoToDealer"
    static let DealerToCar = "DealerToCar"
    static let CarToEndRegistration = "CarToEndRegistration"
    static let CarToCheckVin = "CarToCheckVin"
}

public struct CellIdentifiers {
    static let CarChoosingCell = "CarChoosingCell"
}
