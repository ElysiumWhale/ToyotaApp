import UIKit

enum RegistrationStates {
    case error(message: String)
    case firstPage
    case secondPage(_ profile: Profile, _ cities: [City]?)
}

class NavigationService: MainQueueRunnable {
    static var switchRootView: ((UIViewController) -> Void)?

    class func resolveNavigation(with context: CheckUserContext, fallbackCompletion: Closure) {
        switch context.state {
            case .empty:
                fallbackCompletion()
            case .main(let user):
                loadMain(from: user)
            case .startRegister:
                loadRegister(.firstPage)
            case .register(let page, let user, let cities):
                switch page {
                    case 2:
                        loadRegister(.secondPage(user.profile, cities))
                    default: fallbackCompletion()
                }
        }
    }

    // MARK: - LoadConnectionLost
    class func loadConnectionLost() {
        switchRootView?(UtilsFlow.connectionLostModule())
    }

    // MARK: - LoadAuth
    class func loadAuth(with error: String? = nil) {
        if let error = error {
            PopUp.display(.error(description: error))
        }

        switchRootView?(AuthFlow.entryPoint())
    }

    // MARK: - LoadRegister overloads
    class func loadRegister(_ state: RegistrationStates) {
        var controllers: [UIViewController] = []
        switch state {
            case .error(let message):
                PopUp.display(.error(description: message))
            case .firstPage: break
            case .secondPage(let profile, let cities):
                let carModule = .cityIsSelected ? RegisterFlow.addCarModule() : nil
                controllers = [RegisterFlow.personalInfoModule(profile),
                               RegisterFlow.cityModule(cities),
                               carModule].compactMap { $0 }
        }

        switchRootView?(RegisterFlow.entryPoint(with: controllers))
    }

    // MARK: - LoadMain overloads
    class func loadMain(from user: RegisteredUser? = nil) {
        if let user = user {
            KeychainManager.set(user.profile.toDomain())
            if let cars = user.cars {
                KeychainManager.set(Cars(cars))
            }
        }

        switch UserInfo.build() {
            case .failure:
                loadRegister(.error(message: .error(.profileLoadError)))
            case .success(let user):
                switchRootView?(MainMenuFlow.entryPoint(with: user))
        }
    }
}

// MARK: - setUserForChildren
extension UITabBarController {
    func setUserForChildren(_ user: UserProxy) {
        viewControllers?.forEach { controller in
            if let navigationController = controller as? UINavigationController {
                navigationController.setUserForChildren(user)
            } else if let withUser = controller as? WithUserInfo {
                withUser.setUser(info: user)
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
