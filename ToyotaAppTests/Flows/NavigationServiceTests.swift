import XCTest
@testable import ToyotaApp

@MainActor
final class NavigationServiceTests: XCTestCase {
    private let environment = NavigationService.Environment(
        service: InfoService(),
        newService: NewInfoService(),
        defaults: DefaultsService(container: .init(name: "test")),
        keychain: KeychainService(wrapper: .init(serviceName: "test"))
    )

    override func setUpWithError() throws {
        NavigationService.environment = environment
    }

    override func tearDownWithError() throws {
        environment.keychain.removeAll()
        environment.defaults.removeAll()
    }

    // MARK: - Auth
    func testAuth() {
        NavigationService.switchRootView = { [unowned self] entry in
            testNavigationStackTop(entry, AuthViewController.self)
        }
        NavigationService.loadAuth()
    }

    // MARK: - Register
    func testRegisterErrorState() {
        testRegisterPage(state: .error(message: .empty), modulesCount: 1) { router in
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is PersonalInfoViewController }
            ))
        }
    }

    func testRegisterFirstPage() {
        testRegisterPage(state: .firstPage, modulesCount: 1) { router in
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is PersonalInfoViewController }
            ))
        }
    }

    func testRegisterSecondPage() {
        let city: City? = nil
        environment.defaults.set(value: city, key: .selectedCity)

        testRegisterPage(state: .secondPage(.mock, nil), modulesCount: 2) { router in
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is PersonalInfoViewController }
            ))
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is CityPickerViewController }
            ))
        }
    }

    func testRegisterThirdPage() {
        let city = City(id: .empty, name: .empty)
        environment.defaults.set(value: city, key: .selectedCity)

        testRegisterPage(state: .secondPage(.mock, []), modulesCount: 3) { router in
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is PersonalInfoViewController }
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
            environment.keychain.removeAll()
        }

        environment.keychain.set(UserId(value: .empty))
        environment.keychain.set(Phone(value: .empty))
        NavigationService.loadMain(from: .init(profile: .mock, cars: [.mock]))
    }

    /// TEST: Flow falls back to `loadRegister` because of `UserId` and `Phone` lack
    func testMainFailureOnlyPersonInfo() {
        NavigationService.switchRootView = { [unowned self] in
            testNavigationStackTop($0, AuthViewController.self)
            environment.keychain.removeAll()
        }

        NavigationService.loadMain(from: .init(profile: .mock, cars: [.mock]))
    }

    func testMainSuccessExistedFullUserInfo() {
        NavigationService.switchRootView = { [unowned self] entry in
            testMainSuccessFlow(entry)
            environment.keychain.removeAll()
        }

        environment.keychain.set(UserId(value: .empty))
        environment.keychain.set(Phone(value: .empty))
        environment.keychain.set(Profile.mock.toDomain())
        NavigationService.loadMain()
    }

    func testMainFailureEmptyInfo() {
        NavigationService.switchRootView = { [unowned self] in
            testNavigationStackTop($0, AuthViewController.self)
        }

        NavigationService.loadMain()
    }

    func testMainWithUserIdAndPhoneFailure() {
        NavigationService.switchRootView = { [unowned self] in
            testNavigationStackTop($0, PersonalInfoViewController.self)
            environment.keychain.removeAll()
        }

        environment.keychain.set(UserId(value: .empty))
        environment.keychain.set(Phone(value: .empty))
        NavigationService.loadMain()
    }

    // MARK: - Test resolving navigation
    func testResolveNavigationEmptyFallback() {
        var fallbackDidHit = false
        NavigationService.resolveNavigation(
            context: .empty,
            fallbackCompletion: { fallbackDidHit = true }
        )
        XCTAssertTrue(fallbackDidHit)
    }

    func testResolveNavigationStartRegister() {
        NavigationService.switchRootView = { [unowned self] module in
            testNavigationStackTop(module, PersonalInfoViewController.self)
        }

        NavigationService.resolveNavigation(
            context: .startRegister,
            fallbackCompletion: { XCTFail() }
        )
    }

    func testResolveNavigationRegisterSecondPage() {
        NavigationService.switchRootView = { [unowned self] module in
            testNavigationStackTop(module, CityPickerViewController.self)
        }

        NavigationService.resolveNavigation(
            context: .register(2, .init(profile: .mock, cars: []), []),
            fallbackCompletion: { XCTFail() }
        )
    }

    func testResolveNavigationRegisterFallback() {
        var fallbackDidHit = false
        NavigationService.resolveNavigation(
            context: .register(3, .init(profile: .mock, cars: []), []),
            fallbackCompletion: { fallbackDidHit = true }
        )
        XCTAssertTrue(fallbackDidHit)
    }

    func testResolveNavigationMain() {
        NavigationService.switchRootView = { [unowned self] module in
            testMainSuccessFlow(module)
            environment.keychain.removeAll()
        }

        environment.keychain.set(UserId(value: .empty))
        environment.keychain.set(Phone(value: .empty))
        NavigationService.resolveNavigation(
            context: .main(.init(profile: .mock, cars: [])),
            fallbackCompletion: { XCTFail() }
        )
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

    func testNavigationStackTop<T: UIViewController>(
        _ root: UIViewController,
        _ entryType: T.Type
    ) {
        guard let router = root as? UINavigationController else {
            XCTFail()
            return
        }

        XCTAssertTrue(router.topViewController is T)
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
