import Foundation
import UIKit

class NavigationService {
//    #warning("not work")
//    class func instantinateXIB<T>( _ viewController: T.Type) -> T {
//        let s = String(describing:viewController)
//        let view = Bundle.main.loadNibNamed(s, owner: viewController, options: nil)?.first
//        return view as! T
//    }
    
    class func resolveNavigation(with context: CheckUserOrSmsCodeResponse, fallbackCompletion: (String?) -> Void) {
        if context.registerStatus == nil, let page = context.registerPage,
           let user = context.registeredUser, page > 1 {
            switch page {
                case 2:
                    if let cities = context.cities {
                        NavigationService.loadRegister(with: user.profile, and: cities)
                    } else { fallbackCompletion(AppErrors.serverBadResponse.rawValue) }
                case 3:
                    if let cities = context.cities,
                       let showrooms = user.showroom {
                           NavigationService.loadRegister(with: user, cities, showrooms)
                    } else { fallbackCompletion(AppErrors.serverBadResponse.rawValue) }
                default: fallbackCompletion(AppErrors.serverBadResponse.rawValue)
            }
        } else if let _ = context.registerStatus {
            NavigationService.loadMain(from: context.registeredUser)
        } else if let page = context.registerPage, page == 1 {
            NavigationService.loadRegister()
        } else { fallbackCompletion(AppErrors.serverBadResponse.rawValue) }
    }
    
    private class func configureNavigationStack(with controllers: [UIViewController]? = nil, for storyboard: UIStoryboard, identifier: String) -> UINavigationController {
        let controller = storyboard.instantiateViewController(identifier: identifier) as! UINavigationController
        controller.navigationBar.tintColor = UIColor.mainAppTint
        if let controllers = controllers, !controllers.isEmpty {
            controller.setViewControllers(controllers, animated: false)
        }
        return controller
    }
    
    private class func switchRootView(controller: UIViewController) {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller)
    }
}

extension NavigationService {
    class func loadStoryboard(with name: String, controller: String,
                              configure: @escaping (UIViewController) -> Void = {_ in }) {
        DispatchQueue.main.async {
            let storyBoard: UIStoryboard = UIStoryboard(name: name, bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: controller)
            configure(vc)
            switchRootView(controller: vc)
        }
    }
}

extension NavigationService {
    class func loadConnectionLost() {
        let storyboard = UIStoryboard(name: AppStoryboards.main, bundle: nil)
        DispatchQueue.main.async {
            let controller = storyboard.instantiateViewController(identifier: AppViewControllers.connectionLost) as! ConnectionLostViewController
            //controller.configure()
            switchRootView(controller: controller)
        }
    }
}

//MARK: - LoadAuth
extension NavigationService {
    class func loadAuth(with error: String? = nil) {
        let authStoryboard = UIStoryboard(name: AppStoryboards.auth, bundle: nil)
        DispatchQueue.main.async {
            let controller = configureNavigationStack(for: authStoryboard, identifier: AppViewControllers.authNavigation)
            switchRootView(controller: controller)
            if let error = error {
                controller.displayError(with: error)
            }
        }
    }
    
    class func loadAuth(from navigationController: UINavigationController, with notificator: Notificator) {
        let storyboard = UIStoryboard(name: AppStoryboards.auth, bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: AppViewControllers.auth) as! AuthViewController
        controller.configure(with: .changeNumber(with: notificator))
        navigationController.pushViewController(controller, animated: true)
    }
}

//MARK: - LoadRegister overloads
extension NavigationService {
    class func loadRegister(with error: String? = nil) {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async {
            let controller = configureNavigationStack(for: regStoryboard, identifier: AppViewControllers.registerNavigation)
            switchRootView(controller: controller)
            if let error = error {
                controller.displayError(with: error)
            }
        }
    }
    
    class func loadRegister(with profile: Profile, and cities: [City]) {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async {
            let pivc = regStoryboard.instantiateViewController(identifier: AppViewControllers.personalInfo) as! PersonalInfoViewController
            pivc.configure(with: profile)
            
            let dvc = regStoryboard.instantiateViewController(identifier: AppViewControllers.dealer) as! DealerViewController
            dvc.configure(cityList: cities)
            
            let controller = configureNavigationStack(with: [pivc, dvc], for: regStoryboard, identifier: AppViewControllers.registerNavigation)
            switchRootView(controller: controller)
        }
    }
    
    class func loadRegister(with user: RegisteredUser, _ cities: [City], _ showrooms: [DTOShowroom]) {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: nil)
        DispatchQueue.main.async {
            let pivc = regStoryboard.instantiateViewController(identifier: AppViewControllers.personalInfo) as! PersonalInfoViewController
            pivc.configure(with: user.profile)
            
            let dvc = regStoryboard.instantiateViewController(identifier: AppViewControllers.dealer) as! DealerViewController
            
            let firstShowroom = user.showroom!.first!
            let cityName = firstShowroom.cityName
            let index = cities.firstIndex(where: { $0.name == cityName })!
            
            dvc.configure(cityList: cities, showroomList: showrooms, city: cities[index], showroom: firstShowroom)
            
            let cvvc = regStoryboard.instantiateViewController(identifier: AppViewControllers.checkVin) as! CheckVinViewController
            cvvc.configure(with: firstShowroom.toDomain())
            
            let controller = configureNavigationStack(with: [pivc, dvc, cvvc], for: regStoryboard, identifier: AppViewControllers.registerNavigation)
            switchRootView(controller: controller)
        }
    }
}

//MARK: - LoadMain overloads
extension NavigationService {
    class func loadMain(from user: RegisteredUser? = nil) {
        let mainStoryboard = UIStoryboard(name: AppStoryboards.mainMenu, bundle: nil)
        DispatchQueue.main.async {
            let controller = mainStoryboard.instantiateViewController(identifier: AppViewControllers.mainMenuTabBar) as! UITabBarController
            
            if let user = user {
                DefaultsManager.pushUserInfo(info: Person.toDomain(user.profile))
                DefaultsManager.pushUserInfo(info: Showrooms(user.showroom!.map { Showroom(id: $0.id, showroomName: $0.showroomName, cityName: $0.cityName!) }))
                if let cars = user.car {
                    DefaultsManager.pushUserInfo(info: Cars(cars.map { $0.toDomain() }))
                }
            }
            
            switch UserInfo.build() {
                case .failure(_):
                    loadRegister(with: "При загрузке профиля возникла ошибка, повторите регистрацию для корректного внесения и сохранения данных")
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
}
