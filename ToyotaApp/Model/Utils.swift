import Foundation

public enum AppStoryboards : String {
    case launchScreen = "LaunchScreen"
    case auth = "Authentification"
    case main = "Main"
}

public enum AppViewControllers : String {
    case mainMenuNavigation = "MainMenuNavigationController"
    case auth = "AuthViewController"
    case mainMenu = "MainMenuViewController"
    case tech = "TechViewController"
    case service = "ServiceViewController"
    case myCar = "MyCarViewController"
}

public enum UserDefaultsKeys : String {
    case username = "username"
}
