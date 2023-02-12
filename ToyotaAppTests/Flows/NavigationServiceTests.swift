import XCTest
@testable import ToyotaApp

@MainActor
final class NavigationServiceTests: XCTestCase {
    var city: City?

    override func setUpWithError() throws {
        NavigationService.environment = .init(
            service: InfoService(),
            newService: NewInfoService(),
            defaults: DefaultsService(container: .init(name: "test")),
            keychain: KeychainService(wrapper: .init(serviceName: "test"))
        )
    }

    override func tearDownWithError() throws {
        NavigationService.environment.keychain.removeAll()
        NavigationService.environment.defaults.removeAll()
    }

    // MARK: - Auth
    func testAuth() {
        NavigationService.switchRootView = { entry in
            guard let router = entry as? UINavigationController else {
                XCTFail()
                return
            }

            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is AuthViewController }
            ))
        }
        NavigationService.loadAuth()
    }

    // MARK: - Register
    func testRegisterErrorState() {
        testRegisterPage(state: .error(message: .empty), modulesCount: 1) { router in
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is PersonalInfoView }
            ))
        }
    }

    func testRegisterFirstPage() {
        testRegisterPage(state: .firstPage, modulesCount: 1) { router in
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is PersonalInfoView }
            ))
        }
    }

    func testRegisterSecondPage() {
        let city: City? = nil
        DefaultsService.shared.set(value: city, key: .selectedCity)

        testRegisterPage(state: .secondPage(.mock, nil), modulesCount: 2) { router in
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is PersonalInfoView }
            ))
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is CityPickerViewController }
            ))
        }
    }

    func testRegisterThirdPage() {
        let city = City(id: .empty, name: .empty)
        DefaultsService.shared.set(value: city, key: .selectedCity)

        testRegisterPage(state: .secondPage(.mock, []), modulesCount: 3) { router in
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is PersonalInfoView }
            ))
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is CityPickerViewController }
            ))
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is AddCarViewController }
            ))
            XCTAssertTrue(router.topViewController is AddCarViewController)
        }
    }

    // MARK: - Main
    func testMainSuccessFullUserInfo() {
        NavigationService.switchRootView = { [unowned self] entry in
            testMainSuccessFlow(entry)
            NavigationService.environment.keychain.removeAll()
        }

        NavigationService.environment.keychain.set(UserId(.empty))
        NavigationService.environment.keychain.set(Phone(.empty))
        NavigationService.loadMain(from: .init(profile: .mock, cars: [.mock]))
    }

    /// TEST: Flow falls back to `loadRegister` because of `UserId` and `Phone` lack
    func testMainFailureOnlyPersonInfo() {
        NavigationService.switchRootView = { [unowned self] in
            testMainFailureFlow($0, AuthViewController.self)
            NavigationService.environment.keychain.removeAll()
        }

        NavigationService.loadMain(from: .init(profile: .mock, cars: [.mock]))
    }

    func testMainSuccessExistedFullUserInfo() {
        NavigationService.switchRootView = { [unowned self] entry in
            testMainSuccessFlow(entry)
            NavigationService.environment.keychain.removeAll()
        }

        NavigationService.environment.keychain.set(UserId(.empty))
        NavigationService.environment.keychain.set(Phone(.empty))
        NavigationService.environment.keychain.set(Profile.mock.toDomain())
        NavigationService.loadMain()
    }

    func testMainFailureEmptyInfo() {
        NavigationService.switchRootView = { [unowned self] in
            testMainFailureFlow($0, AuthViewController.self)
        }

        NavigationService.loadMain()
    }

    func testMainWithUserIdAndPhoneFailure() {
        NavigationService.switchRootView = { [unowned self] in
            testMainFailureFlow($0, PersonalInfoView.self)
            NavigationService.environment.keychain.removeAll()
        }

        NavigationService.environment.keychain.set(UserId(.empty))
        NavigationService.environment.keychain.set(Phone(.empty))
        NavigationService.loadMain()
    }
}

// MARK: - Helpers
extension NavigationServiceTests {
    private func testRegisterPage(
        state: NavigationService.RegistrationStates,
        modulesCount: Int,
        testRouterClosure: @escaping (UINavigationController) -> Void
    ) {
        NavigationService.switchRootView = { view in
            guard let router = view as? UINavigationController else {
                XCTFail()
                return
            }
            XCTAssertEqual(router.viewControllers.count, modulesCount)
            testRouterClosure(router)
        }

        NavigationService.loadRegister(state)
    }

    func testMainFailureFlow<T: UIViewController>(
        _ root: UIViewController,
        _ entryType: T.Type
    ) {
        guard let router = root as? UINavigationController else {
            XCTFail()
            return
        }

        XCTAssertTrue(router.viewControllers.contains(where: { $0 is T }))
    }

    func testMainSuccessFlow(_ root: UIViewController) {
        guard let tabHolder = root as? MainTabBarController else {
            XCTFail()
            return
        }

        XCTAssertNotNil(tabHolder.tabsRoots[.news])
        XCTAssertTrue(tabHolder.tabsRoots[.news]?.topViewController is NewsViewController)
        XCTAssertNotNil(tabHolder.tabsRoots[.services])
        XCTAssertTrue(tabHolder.tabsRoots[.services]?.topViewController is ServicesViewController)
        XCTAssertNotNil(tabHolder.tabsRoots[.profile])
        XCTAssertTrue(tabHolder.tabsRoots[.profile]?.topViewController is ProfileViewController)
    }
}
