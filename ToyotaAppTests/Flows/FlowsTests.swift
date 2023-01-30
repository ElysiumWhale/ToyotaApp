import XCTest
@testable import ToyotaApp

@MainActor
final class FlowsTests: XCTestCase {
    func testAuthFlow() throws {
        let authModule = AuthFlow.authModule(authType: .register)
        XCTAssertTrue(authModule is AuthViewController)

        let codeModule = AuthFlow.codeModule(phone: "1", authType: .register)
        XCTAssertTrue(codeModule is SmsCodeViewController)

        let entry = AuthFlow.entryPoint(with: [authModule, codeModule])
        guard let nvc = entry as? UINavigationController else {
            XCTFail()
            return
        }
        XCTAssertTrue(nvc.topViewController is SmsCodeViewController)
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

        guard let nvc = entry as? UINavigationController else {
            XCTFail()
            return
        }
        XCTAssertTrue(nvc.topViewController is AddCarViewController)
    }

    func testMainMenuFlow() throws {
        let tab = MainMenuFlow.entryPoint(for: .mock)
        XCTAssertTrue(tab.root is MainTabBarController)
        XCTAssertTrue(tab.tabsRoots[.news]?.topViewController is NewsViewController)
        XCTAssertTrue(tab.tabsRoots[.services]?.topViewController is ServicesViewController)
        XCTAssertTrue(tab.tabsRoots[.profile]?.topViewController is ProfileViewController)
    }

    func testMainMenuFlowFabrics() throws {
        let news = MainMenuFlow.newsModule()
        XCTAssertTrue(news is NewsViewController)

        let chat = MainMenuFlow.chatModule()
        XCTAssertTrue(chat is ChatViewController)

        let payload = MainMenuFlow.ServicesPayload(user: .mock)
        let services = MainMenuFlow.servicesModule(payload)
        XCTAssertTrue(services is ServicesViewController)

        let payload1 = MainMenuFlow.ProfilePayload(user: .mock)
        let profile = MainMenuFlow.profileModule(payload1)
        XCTAssertTrue(profile is ProfileViewController)

        let payload2 = MainMenuFlow.BookingsPayload(userId: "-1")
        let bookings = MainMenuFlow.bookingsModule(payload2)
        XCTAssertTrue(bookings is BookingsViewController)

        let payload3 = MainMenuFlow.SettingsPayload(user: .mock)
        let settings = MainMenuFlow.settingsModule(payload3)
        XCTAssertTrue(settings is SettingsViewController)

        let payload4 = MainMenuFlow.ManagersPayload(userId: "-1")
        let managers = MainMenuFlow.managersModule(payload4)
        XCTAssertTrue(managers is ManagersViewController)

        let payload5 = MainMenuFlow.CarsPayload(user: .mock)
        let cars = MainMenuFlow.carsModule(payload5)
        XCTAssertTrue(cars is CarsViewController)
    }

    func testSettingsModuleOutput() {
        let payload = MainMenuFlow.SettingsPayload(user: .mock)
        let settingsModule = MainMenuFlow.settingsModule(payload)
        var expectations = [SettingsOutput: Bool]()
        settingsModule.withOutput { expectations[$0] = true }
        settingsModule.sendAllOutputs()
        XCTAssertTrue(expectations.count == SettingsOutput.allCases.count)
        XCTAssertTrue(expectations.allSatisfy(\.value))
    }

    func testProfileModuleOutput() {
        let payload = MainMenuFlow.ProfilePayload(user: .mock)
        let module = MainMenuFlow.profileModule(payload)
        var expectations = [ProfileOutput: Bool]()
        module.withOutput { expectations[$0] = true }
        module.sendAllOutputs()
        XCTAssertTrue(expectations.count == ProfileOutput.allCases.count)
        XCTAssertTrue(expectations.allSatisfy(\.value))
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

private extension Outputable where TOutput: CaseIterable {
    func sendAllOutputs() {
        for item in TOutput.allCases {
            output?(item)
        }
    }
}
