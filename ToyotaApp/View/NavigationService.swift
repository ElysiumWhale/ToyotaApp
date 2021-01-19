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
    
    class func resolveNavigation(with context: CheckUserOrSmsCodeResponse, fallbackCompletion: () -> Void) {
        if context.registerStatus == nil, let page = context.registerPage,
           let user = context.registeredUser, page > 1
            {
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
                    #warning("redundant??")
                    if let profile = user.profile,
                       let showrooms = user.showroom,
                       let cars = user.car {
                           NavigationService.loadMain(with: profile, showrooms, and: cars)
                    } else { fallbackCompletion() }
                default: fallbackCompletion()
            }
        } else if let _ = context.registerStatus {
            NavigationService.loadMain(from: context.registeredUser)
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
            cvvc.showroomId = user.showroom!.first!.id
            
            let controller = configureNavigationStack(with: [pivc, dvc, cvvc], for: regStoryboard, identifier: AppViewControllers.registerNavigation)
            switchRootView(controller: controller)
        }
    }
}

//MARK: - LoadNain overloads
extension NavigationService {
    
    #warning("redundant??")
    class func loadMain(with profile: Profile, _ showrooms: [RegisteredUser.Showroom], and cars: [DTOCar]) {
        let mainStoryboard = UIStoryboard(name: AppStoryboards.main, bundle: nil)
        DispatchQueue.main.async {
            let controller = mainStoryboard.instantiateViewController(identifier: AppViewControllers.mainMenuTabBarController) as! UITabBarController
            
            //pushTestCars()
            
            let result = DefaultsManager.buildUserFromDefaults()
            switch result {
                case .failure:
                    DefaultsManager.pushUserInfo(info: UserInfo.PersonInfo.toDomain(profile: profile))
                    DefaultsManager.pushUserInfo(info: UserInfo.Showrooms(showrooms.map { Showroom($0.id, $0.showroomName, $0.cityName) }))
                    DefaultsManager.pushUserInfo(info: UserInfo.Cars(cars.map { $0.toDomain() }))
                case .success(let user):
                    for child in controller.viewControllers ?? [] {
                        if let top = child as? WithUserInfo {
                            top.setUser(info: user)
                        } else if let nav = child as? UINavigationController, let top = nav.topViewController as? WithUserInfo {
                            top.setUser(info: user)
                        }
                    }
            }
            switchRootView(controller: controller)
        }
    }
    
    class func loadMain(from user: RegisteredUser? = nil) {
        let mainStoryboard = UIStoryboard(name: AppStoryboards.main, bundle: nil)
        DispatchQueue.main.async {
            let controller = mainStoryboard.instantiateViewController(identifier: AppViewControllers.mainMenuTabBarController) as! UITabBarController
            
            if let user = user {
                DefaultsManager.pushUserInfo(info: UserInfo.PersonInfo.toDomain(profile: user.profile!))
                DefaultsManager.pushUserInfo(info: UserInfo.Showrooms(user.showroom!.map { Showroom($0.id, $0.showroomName,     $0.cityName) }))
                if let cars = user.car {
                    DefaultsManager.pushUserInfo(info: UserInfo.Cars(cars.map { $0.toDomain() }))
                }
            }
            
            //pushTestCars()
            
            switch DefaultsManager.buildUserFromDefaults() {
                case .failure(_):
                    loadRegister()
                    PopUp.displayMessage(with: "Ошибка", description: "При загрузке профиля возникла ошибка, повторите регистрацию для корректного внесения и сохранения данных", buttonText: "Ок")
                case .success(let user):
                    for child in controller.viewControllers! {
                        if let top = child as? WithUserInfo {
                            top.setUser(info: user)
                        } else if let nav = child as? UINavigationController,
                                  let top = nav.topViewController as? WithUserInfo {
                            top.setUser(info: user)
                        }
                    }
                    switchRootView(controller: controller)
            }
        }
    }
    
    private class func pushTestCars() {
        let car = Car(id: "1", showroomId: "2", brand: "Toyota", model: "Supra A90", color: "Белый жемчуг", colorSwatch: "#eeee", colorDescription: "Белый красивый", isMetallic: "1", plate: "а228аа163rus", vin: "22822822822822822")
         let car1 = Car(id: "2", showroomId: "1", brand: "Toyota", model: "Camry 3.5", color: "Черный жемчуг", colorSwatch: "#eeee", colorDescription: "Черный красивый", isMetallic: "1", plate: "м148мм163rus", vin: "22822822822822822")
         DefaultsManager.pushUserInfo(info: UserInfo.Cars([car, car1], chosen: car))
         DefaultsManager.pushAdditionalInfo(info: car, for: "chosenCar")
    }
}
