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
    class func loadMain(with profile: Profile, _ showrooms: [RegisteredUser.Showroom], and cars: [DTOCar]) {
        let mainStoryboard = UIStoryboard(name: AppStoryboards.main, bundle: nil)
        DispatchQueue.main.async {
            let controller = mainStoryboard.instantiateViewController(identifier: AppViewControllers.mainMenuTabBarController) as! UITabBarController
            
            let car = Car(id: "1", showroomId: "2", brand: "Toyota", model: "Supra A90", color: "Белый жемчуг", colorSwatch: "#eeee", colorDescription: "Белый красивый", isMetallic: "1", plate: "а228аа163rus", vin: "22822822822822822")
            let car1 = Car(id: "2", showroomId: "1", brand: "Toyota", model: "Camry 3.5", color: "Черный жемчуг", colorSwatch: "#eeee", colorDescription: "Черный красивый", isMetallic: "1", plate: "а228аа163rus", vin: "22822822822822822")
            DefaultsManager.pushUserInfo(info: UserInfo.Cars(array: [car, car1]))
            
            let result = DefaultsManager.buildUserFromDefaults()
            switch result {
                case .failure:
                    #warning("push all info")
                    print("Configure with injected params")
                case .success(let user):
                    for child in controller.viewControllers ?? [] {
                          if let top = child as? WithUserInfo {
                            top.setUser(info: user)
                        }
                    }
            }
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller)
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
                       let showrooms = context.showrooms {
                        NavigationService.loadRegister(with: user, cities, showrooms)
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
    
    class func loadRegister(with user: RegisteredUser, _ cities: [City], _ showrooms: [DTOShowroom]) {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async {
            let pivc = regStoryboard.instantiateViewController(identifier:      AppViewControllers.personalInfoViewController) as! PersonalInfoViewController
            pivc.configure(with: user.profile!)
            
            let dvc = regStoryboard.instantiateViewController(identifier:       AppViewControllers.dealerViewController) as! DealerViewController
            let index = cities.firstIndex(where: { $0.name == user.showroom!.first!.cityName })!
            dvc.configure(cityList: cities, showroomList: showrooms, city: cities[index], showroom: user.showroom!.first)
            
            let cvvc = regStoryboard.instantiateViewController(identifier: AppViewControllers.checkVinViewController) as! CheckVinViewController
            
            let controller = configureNavigationStack(with: [pivc, dvc, cvvc], for: regStoryboard, identifier: AppViewControllers.registerNavigation)
            switchRootView(controller: controller)
        }
    }
}
