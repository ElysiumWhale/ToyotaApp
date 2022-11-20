import XCTest
@testable import ToyotaApp

final class FlowsTests: XCTestCase {
    func testAuthFlow() throws {
        let authModule = AuthFlow.authModule(authType: .register)
        XCTAssertTrue(authModule is AuthViewController)

        let codeModule = AuthFlow.codeModule(phone: "1", authType: .register)
        XCTAssertTrue(codeModule is SmsCodeViewController)

        let entry = AuthFlow.entryPoint(with: [authModule, codeModule])
        XCTAssertTrue(entry is UINavigationController)
        let nvc = entry as? UINavigationController
        XCTAssertTrue(nvc!.topViewController is SmsCodeViewController)
    }

    func testRegisterFlow() throws {
        let personalModule = RegisterFlow.personalModule()
        XCTAssertTrue(personalModule is PersonalInfoView)

        let cityModule = RegisterFlow.cityModule([])
        XCTAssertTrue(cityModule is CityPickerViewController)

        let addCarModule = RegisterFlow.addCarModule()
        XCTAssertTrue(addCarModule is AddCarViewController)

        let endRegistrationModule = RegisterFlow.endRegistrationModule()
        XCTAssertTrue(endRegistrationModule is EndRegistrationViewController)

        let entry = RegisterFlow.entryPoint(
            with: [personalModule, cityModule, addCarModule]
        )
        XCTAssertTrue(entry is UINavigationController)
        let nvc = entry as? UINavigationController
        XCTAssertTrue(nvc!.topViewController is AddCarViewController)
    }

    func testMainMenuFlow() throws {
        let tab = MainMenuFlow.entryPoint(for: .mock)
        XCTAssertTrue(tab.root is MainTabBarController)
        XCTAssertTrue(tab.tabsRoots[.news]?.topViewController is NewsViewController)
        XCTAssertTrue(tab.tabsRoots[.services]?.topViewController is ServicesViewController)
        XCTAssertTrue(tab.tabsRoots[.profile]?.topViewController is ProfileViewController)
    }

    func testMainMenuFlowFabrics() throws {
        let chat = MainMenuFlow.chatModule()
        XCTAssertTrue(chat is ChatViewController)

        let services = MainMenuFlow.servicesModule(
            with: MainMenuFlow.ServicesPayload(user: .mock)
        )
        XCTAssertTrue(services is ServicesViewController)

        let profile = MainMenuFlow.profileModule(
            with: MainMenuFlow.ProfilePayload(user: .mock)
        )
        XCTAssertTrue(profile is ProfileViewController)

        let news = MainMenuFlow.newsModule()
        XCTAssertTrue(news is NewsViewController)

        let bookings = MainMenuFlow.bookingsModule(
            with: MainMenuFlow.BookingsPayload(userId: "-1")
        )
        XCTAssertTrue(bookings is BookingsViewController)

        let settings = MainMenuFlow.settingsModule(
            with: MainMenuFlow.SettingsPayload(user: .mock)
        )
        XCTAssertTrue(settings is SettingsViewController)

        let managers = MainMenuFlow.managersModule(
            with: MainMenuFlow.ManagersPayload(userId: "-1")
        )
        XCTAssertTrue(managers is ManagersViewController)

        let cars = MainMenuFlow.carsModule(
            with: MainMenuFlow.CarsPayload(user: .mock)
        )
        XCTAssertTrue(cars is CarsViewController)
    }

    func testUtilsFlow() throws {
        let connection = UtilsFlow.connectionLostModule()
        XCTAssertTrue(connection is LostConnectionViewController)

        let agreement = UtilsFlow.agreementModule()
        XCTAssertTrue(agreement is AgreementViewController)

        let splash = UtilsFlow.splashScreenModule()
        XCTAssertTrue(splash is SplashScreenViewController)
    }

    func testServicesFlow() throws {
        let service = ServicesFlow.buildModule(
            serviceType: .mock,
            for: .onePick,
            user: .mock
        )
        XCTAssertTrue(service is BaseServiceController)

        let testDrive = ServicesFlow.buildModule(
            serviceType: .testDriveMock,
            for: .onePick,
            user: .mock
        )
        XCTAssertTrue(testDrive is TestDriveViewController)
    }
}

private extension ServiceType {
    static var mock: Self {
        .init(
            id: .empty,
            serviceTypeName: .empty,
            controlTypeId: .empty,
            controlTypeDesc: .empty
        )
    }

    static var testDriveMock: Self {
        .init(
            id: CustomServices.TestDrive,
            serviceTypeName: .empty,
            controlTypeId: .empty,
            controlTypeDesc: .empty
        )
    }
}
