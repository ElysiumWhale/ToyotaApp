import UIKit

enum RoutingTypes {
    case selfRouted
    case routed(by: UINavigationController)
    case none
}

@MainActor
final class NavigationService {
    enum RegistrationStates {
        case error(message: String)
        case firstPage
        case secondPage(_ profile: Profile, _ cities: [City]?)
    }

    static var switchRootView: ((UIViewController) -> Void)?

    static func resolveNavigation(
        with context: CheckUserContext,
        fallbackCompletion: Closure
    ) {
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
        case let .error(message):
            PopUp.display(.error(description: message))
        case .firstPage:
            break
        case let .secondPage(profile, cities):
            let personalModule = RegisterFlow.personalModule(profile)
            let cityModule = RegisterFlow.cityModule(cities ?? [])
            let carModule = .cityIsSelected ? RegisterFlow.addCarModule() : nil
            let router = personalModule.navigationController

            cityModule.withOutput { [weak router] output in
                switch output {
                case .cityDidPick:
                    let carModule = RegisterFlow.addCarModule()
                    router?.pushViewController(carModule, animated: true)
                }
            }

            controllers = [
                personalModule,
                cityModule,
                carModule
            ].compactMap { $0 }
        }

        switchRootView?(RegisterFlow.entryPoint(with: controllers))
    }

    // MARK: - LoadMain overloads
    static func loadMain(from user: RegisteredUser? = nil) {
        if let user = user {
            KeychainService.shared.set(user.profile.toDomain())
            if let cars = user.cars {
                KeychainService.shared.set(Cars(cars))
            }
        }

        switch UserInfo.make(KeychainService.shared) {
        case .failure:
            loadRegister(.error(message: .error(.profileLoadError)))
        case let .success(user):
            let entry = MainMenuFlow.entryPoint(.makeDefault(from: user))
            switchRootView?(entry.root)
        }
    }
}

extension MainMenuFlow.Environment {
    static func makeDefault(from user: UserProxy) -> Self {
        let infoService = InfoService()
        return .init(
            userProxy: user,
            notificator: .shared,
            defaults: DefaultsService.shared,
            keychain: KeychainService.shared,
            newsService: NewsInfoService.init(),
            servicesService: infoService,
            personalService: infoService,
            managersService: infoService,
            carsService: infoService,
            bookingsService: infoService
        )
    }
}
