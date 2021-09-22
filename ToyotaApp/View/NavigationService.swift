import Foundation
import UIKit

// MARK: - Context for navigation
struct CheckUserContext {
    enum States {
        case empty
        case startRegister
        case register(_ page: Int, _ user: RegisteredUser)
        case main(_ user: RegisteredUser?)
    }
    
    let response: CheckUserOrSmsCodeResponse
    
    var state: States {
        if response.registerStatus == nil {
            if response.registerPage == nil || response.registerPage == 1 {
                return .startRegister
            } else if let page = response.registerPage {
                return response.registeredUser != nil ? .register(page, response.registeredUser!) : .empty
            }
        }
        if response.registerStatus != nil, response.registerPage == nil {
            return .main(response.registeredUser)
        }
        return .empty
    }
}

enum RegistrationStates {
    case error(message: String)
    case firstPage
    case secondPage(_ profile: Profile, _ cities: [City])
    case thirdPage(_ user: RegisteredUser, _ cities: [City], _ showrooms: [DTOShowroom])
}
class NavigationService {
    class func resolveNavigation(with context: CheckUserContext, fallbackCompletion: () -> Void) {
        switch context.state {
            case .empty: fallbackCompletion()
            case .main(let user): NavigationService.loadMain(from: user)
            case .startRegister: NavigationService.loadRegister(.firstPage)
            case .register(let page, let user):
                switch page {
                    case 2 where context.response.cities != nil:
                        NavigationService.loadRegister(.secondPage(user.profile, context.response.cities!))
                    case 3 where context.response.cities != nil && user.showroom != nil:
                        NavigationService.loadRegister(.thirdPage(user, context.response.cities!, user.showroom!))
                    default: fallbackCompletion()
                }
        }
    }

    private class func configureNavigationStack(with controllers: [UIViewController]? = nil, for storyboard: UIStoryboard, identifier: String) -> UINavigationController {
        guard let controller = storyboard.instantiateViewController(identifier: identifier) as? UINavigationController else {
            fatalError()
        }
        controller.navigationBar.tintColor = UIColor.appTint(.mainRed)
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
            let controller: ConnectionLostViewController = storyboard.instantiate(.connectionLost)
            // controller.configure()
            switchRootView(controller: controller)
        }
    }
}

// MARK: - LoadAuth
extension NavigationService {
    class func loadAuth(with error: String? = nil) {
        let authStoryboard = UIStoryboard(name: AppStoryboards.auth, bundle: nil)
        DispatchQueue.main.async {
            let controller = configureNavigationStack(for: authStoryboard, identifier: AppViewControllers.authNavigation)
            switchRootView(controller: controller)
            if let error = error {
                PopUp.display(.error(description: error))
            }
        }
    }

    class func loadAuth(from navigationController: UINavigationController, with notificator: Notificator) {
        let storyboard = UIStoryboard(name: AppStoryboards.auth, bundle: nil)
        let controller: AuthViewController = storyboard.instantiate(.auth)
        controller.configure(with: .changeNumber(with: notificator))
        navigationController.pushViewController(controller, animated: true)
    }
}

// MARK: - LoadRegister overloads
extension NavigationService {
    class func loadRegister(_ state: RegistrationStates) {
        let regStoryboard = UIStoryboard(name: AppStoryboards.register, bundle: .main)
        DispatchQueue.main.async {
            var controller: UINavigationController
            var controllers: [UIViewController]?
            switch state {
                case .error(let message):
                    PopUp.display(.error(description: message))
                case .firstPage: break
                case .secondPage(let profile, let cities):
                    let pivc: PersonalInfoViewController = regStoryboard.instantiate(.personalInfo)
                    pivc.configure(with: profile)
                    
                    let dvc: DealerViewController = regStoryboard.instantiate(.dealer)
                    dvc.configure(cityList: cities)
                    
                    controllers = [pivc, dvc]
                case .thirdPage(let user, let cities, let showrooms):
                    let pivc: PersonalInfoViewController = regStoryboard.instantiate(.personalInfo)
                    pivc.configure(with: user.profile)
                    
                    let dvc: DealerViewController = regStoryboard.instantiate(.dealer)
                    let firstShowroom = user.showroom!.first!
                    let cityName = firstShowroom.cityName
                    let index = cities.firstIndex(where: { $0.name == cityName })!
                    dvc.configure(cityList: cities, showroomList: showrooms,
                                   city: cities[index], showroom: firstShowroom)
                    
                    let cvvc: CheckVinViewController = regStoryboard.instantiate(.checkVin)
                    cvvc.configure(with: firstShowroom.toDomain())
                    
                    controllers = [pivc, dvc, cvvc]
            }
            controller = configureNavigationStack(with: controllers, for: regStoryboard,
                                                  identifier: AppViewControllers.registerNavigation)
            switchRootView(controller: controller)
        }
    }
}

// MARK: - LoadMain overloads
extension NavigationService {
    class func loadMain(from user: RegisteredUser? = nil) {
        let mainStoryboard = UIStoryboard(name: AppStoryboards.mainMenu, bundle: nil)
        DispatchQueue.main.async {
            let controller: UITabBarController = mainStoryboard.instantiate(.mainMenuTabBar)
            
            if let user = user {
                KeychainManager.set(Person.toDomain(user.profile))
                KeychainManager.set(Showrooms(user.showroom!.map { Showroom(id: $0.id, showroomName: $0.showroomName, cityName: $0.cityName!) }))
                if let cars = user.car {
                    KeychainManager.set(Cars(cars.map { $0.toDomain() }))
                }
            }
            
            switch UserInfo.build() {
                case .failure:
                    loadRegister(.error(message: .profileLoadError))
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
