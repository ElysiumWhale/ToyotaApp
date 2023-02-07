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

    func testRegisterErrorState() {
        testPage(state: .error(message: .empty), modulesCount: 1) { router in
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is PersonalInfoView }
            ))
        }
    }

    func testRegisterFirstPage() {
        testPage(state: .firstPage, modulesCount: 1) { router in
            XCTAssertTrue(router.viewControllers.contains(
                where: { $0 is PersonalInfoView }
            ))
        }
    }

    func testRegisterSecondPage() {
        let city: City? = nil
        DefaultsService.shared.set(value: city, key: .selectedCity)

        testPage(state: .secondPage(.mock, nil), modulesCount: 2) { router in
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

        testPage(state: .secondPage(.mock, []), modulesCount: 3) { router in
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
}

// MARK: - Helpers
extension NavigationServiceTests {
    private func testPage(
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
}
