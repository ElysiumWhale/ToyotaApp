import Foundation
import UIKit

class NavigationService {
    
    class func loadAuth() {
        let authStoryboard = UIStoryboard(name: AppStoryboards.auth, bundle: nil)
        DispatchQueue.main.async {
            let controller = configureNavigationStack(with: [UIViewController](), for: authStoryboard, identifier: AppViewControllers.authNavigation)
            switchRootView(controller: controller)
        }
    }
    
    //TODO
    class func loadMain(with profile: Profile, _ showrooms: [RegisteredUser.Showroom], and cars: [Car]) {
        let mainStoryboard = UIStoryboard(name: AppStoryboards.main, bundle: nil)
        DispatchQueue.main.async {
            let controller = mainStoryboard.instantiateViewController(identifier: AppViewControllers.mainMenuTabBarController) as? UITabBarController
            //check if user in memory
            //configure
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller!)
        }
    }
    
    class func resolveNavigation(with context: CheckUserOrSmsCodeResponse, fallbackCompletion: () -> Void) {
        if let page = context.registerPage, let user = context.registeredUser, page > 1 {
            switch page {
                case 2:
                    if let profile = user.profile,
                       let cities = context.cities {
                        NavigationService.loadRegister(with: profile, and: cities)
                    } else { fallbackCompletion() }
                case 3:
                    if let cities = context.cities,
                       let showrooms = context.showrooms,
                       let cars = context.cars {
                        NavigationService.loadRegister(with: user, cities, showrooms, and: cars)
                    } else { fallbackCompletion() }
                case 4:
                    if let profile = user.profile,
                       let showrooms = user.showroom,
                       let cars = user.car {
                        NavigationService.loadMain(with: profile, showrooms, and: cars)
                    } else { fallbackCompletion() }
                default: fallbackCompletion()
            }
        } else { fallbackCompletion() }
    }
    
    private class func configureNavigationStack(with controllers: [UIViewController], for storyboard: UIStoryboard, identifier: String) -> UINavigationController {
        let controller = storyboard.instantiateViewController(identifier: identifier) as! UINavigationController
        if !controllers.isEmpty {
            controller.setViewControllers(controllers, animated: false)
        }
        return controller
    }
    
    private class func switchRootView(controller: UIViewController) {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller)
    }
}

//MARK: - LoadRegister overloads
extension NavigationService {
    class func loadRegister() {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async {
            let controller = configureNavigationStack(with: [UIViewController](), for: regStoryboard, identifier: AppViewControllers.registerNavigation)
            switchRootView(controller: controller)
        }
    }
    
    class func loadRegister(with profile: Profile, and cities: [City]) {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async {
            let pivc = regStoryboard.instantiateViewController(identifier:  AppViewControllers.personalInfoViewController) as! PersonalInfoViewController
            pivc.configure(with: profile)
            
            let dvc = regStoryboard.instantiateViewController(identifier:   AppViewControllers.dealerViewController) as! DealerViewController
            dvc.configure(cityList: cities)
            
            let controller = configureNavigationStack(with: [pivc, dvc], for: regStoryboard, identifier: AppViewControllers.registerNavigation)
            switchRootView(controller: controller)
        }
    }
    
    class func loadRegister(with user: RegisteredUser, _ cities: [City], _ showrooms: [Showroom], and cars: [Car]) {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async {
            let pivc = regStoryboard.instantiateViewController(identifier:      AppViewControllers.personalInfoViewController) as! PersonalInfoViewController
            pivc.configure(with: user.profile!)
            
            let dvc = regStoryboard.instantiateViewController(identifier:       AppViewControllers.dealerViewController) as! DealerViewController
            let index = cities.firstIndex(where: { $0.name == user.showroom!.first!.cityName })!
            dvc.configure(cityList: cities, showroomList: showrooms, city: cities[index], showroom: user.showroom!.first)
            
            let acvc = regStoryboard.instantiateViewController(identifier:      AppViewControllers.addingCarViewController) as! AddingCarViewController
            acvc.configure(carsList: cars)
            
            let controller = configureNavigationStack(with: [pivc, dvc, acvc], for: regStoryboard, identifier: AppViewControllers.registerNavigation)
            switchRootView(controller: controller)
        }
    }
}
