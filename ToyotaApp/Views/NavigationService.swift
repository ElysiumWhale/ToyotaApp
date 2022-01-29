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
                return response.registeredUser != nil
                    ? .register(page, response.registeredUser!)
                    : .empty
            }
        }

        if response.registerStatus == 1, response.registerPage == nil {
            return .main(response.registeredUser)
        }

        return .empty
    }
}

enum RegistrationStates {
    case error(message: String)
    case firstPage
    case secondPage(_ profile: Profile, _ cities: [City]?)
}

class NavigationService {
    static var switchRootView: ((UIViewController) -> Void)?

    class func resolveNavigation(with context: CheckUserContext, fallbackCompletion: Closure) {
        switch context.state {
            case .empty:
                fallbackCompletion()
            case .main(let user):
                loadMain(from: user)
            case .startRegister:
                loadRegister(.firstPage)
            case .register(let page, let user):
                switch page {
                    case 2:
                        loadRegister(.secondPage(user.profile, context.response.cities))
                    default: fallbackCompletion()
                }
        }
    }

    private class func configureNavigationStack(with controllers: [UIViewController] = [],
                                                for storyboard: UIStoryboard,
                                                identifier: ViewControllers) -> UINavigationController {
        let controller: UINavigationController = storyboard.instantiate(identifier)
        controller.navigationBar.tintColor = UIColor.appTint(.secondarySignatureRed)
        if !controllers.isEmpty {
            controller.setViewControllers(controllers, animated: false)
        }
        return controller
    }

    // MARK: - LoadConnectionLost
    class func loadConnectionLost() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(.main)
            let controller: ConnectionLostViewController = storyboard.instantiate(.connectionLost)
            switchRootView?(controller)
        }
    }

    // MARK: - LoadAuth
    class func loadAuth(with error: String? = nil) {
        DispatchQueue.main.async {
            let controller = configureNavigationStack(for: UIStoryboard(.auth), identifier: .authNavigation)
            switchRootView?(controller)
            if let error = error {
                PopUp.display(.error(description: error))
            }
        }
    }

    class func loadAuth(from navigationController: UINavigationController, with notificator: Notificator) {
        let controller: AuthViewController = instantinate(from: .auth, id: .auth)
        controller.configure(with: .changeNumber(with: notificator))
        navigationController.pushViewController(controller, animated: true)
    }

    // MARK: - LoadRegister overloads
    class func loadRegister(_ state: RegistrationStates) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(.register)
            var controllers: [UIViewController] = []
            switch state {
                case .error(let message):
                    PopUp.display(.error(description: message))
                case .firstPage: break
                case .secondPage(let profile, let cities):
                    let pivc: PersonalInfoViewController = storyboard.instantiate(.personalInfo)
                    pivc.configure(with: profile)

                    let cpvc: CityPickerViewController = storyboard.instantiate(.cityPick)
                    if let cities = cities {
                        cpvc.configure(with: cities)
                    }

                    if let selectedCity: City = DefaultsManager.getUserInfo(for: .selectedCity) {
                        let acvc: AddCarViewController = storyboard.instantiate(.addCar)
                        controllers = [pivc, cpvc, acvc]
                    } else {
                        controllers = [pivc, cpvc]
                    }
            }
            let controller = configureNavigationStack(with: controllers, for: storyboard,
                                                      identifier: .registerNavigation)
            switchRootView?(controller)
        }
    }

    // MARK: - LoadMain overloads
    class func loadMain(from user: RegisteredUser? = nil) {
        if let user = user {
            KeychainManager.set(Person.toDomain(user.profile))
            if let cars = user.cars {
                KeychainManager.set(Cars(cars))
            }
        }

        switch UserInfo.build() {
            case .failure:
                loadRegister(.error(message: .error(.profileLoadError)))
            case .success(let user):
                DispatchQueue.main.async {
                    let controller: UITabBarController = instantinate(from: .mainMenu, id: .mainMenuTabBar)
                    controller.setUserForChildren(user)
                    switchRootView?(controller)
                }
        }
    }
}

// MARK: - Instantinate
private extension NavigationService {
    static func instantinate<TController: UIViewController>(from storyboard: AppStoryboards,
                                                            id: ViewControllers) -> TController {
        UIStoryboard(storyboard).instantiate(id)
    }
}

// MARK: - setUserForChildren
private extension UITabBarController {
    func setUserForChildren(_ user: UserProxy) {
        viewControllers?.forEach { controller in
            if let navigationController = controller as? UINavigationController {
                navigationController.setUserForChildren(user)
            }
        }
    }
}

// MARK: - setUserForChildren
extension UINavigationController {
    func setUserForChildren(_ user: UserProxy) {
        viewControllers.forEach { controller in
            if let controllerWithUser = controller as? WithUserInfo {
                controllerWithUser.setUser(info: user)
            }
        }
    }
}
