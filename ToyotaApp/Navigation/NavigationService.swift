import UIKit

@MainActor
final class NavigationService: MainQueueRunnable {
    enum RegistrationStates {
        case error(message: String)
        case firstPage
        case secondPage(_ profile: Profile, _ cities: [City]?)
    }

    static var switchRootView: ((UIViewController) -> Void)?

    static func resolveNavigation(with context: CheckUserContext,
                                  fallbackCompletion: Closure) {
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
            default:
                fallbackCompletion()
            }
        }
    }

    // MARK: - LoadConnectionLost
    static func loadConnectionLost() {
        switchRootView?(UtilsFlow.connectionLostModule())
    }

    // MARK: - LoadAuth
    static func loadAuth(with error: String? = nil) {
        if let error = error {
            PopUp.display(.error(description: error))
        }

        switchRootView?(AuthFlow.entryPoint())
    }

    // MARK: - LoadRegister overloads
    static func loadRegister(_ state: RegistrationStates) {
        var controllers: [UIViewController] = []
        switch state {
        case .error(let message):
            PopUp.display(.error(description: message))
        case .firstPage:
            break
        case .secondPage(let profile, let cities):
            let personalModule = RegisterFlow.personalModule(profile)
            let cityModule = RegisterFlow.cityModule(cities ?? [])
            let carModule = .cityIsSelected ? RegisterFlow.addCarModule() : nil

            cityModule.onCityPick = { [weak personalModule] _ in
                let addCar = RegisterFlow.addCarModule()
                personalModule?.navigationController?.pushViewController(addCar, animated: true)
            }

            controllers = [personalModule,
                           cityModule,
                           carModule].compactMap { $0 }
        }

        switchRootView?(RegisterFlow.entryPoint(with: controllers))
    }

    // MARK: - LoadMain overloads
    static func loadMain(from user: RegisteredUser? = nil) {
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
            switchRootView?(MainMenuFlow.entryPoint(for: user).root)
        }
    }
}
