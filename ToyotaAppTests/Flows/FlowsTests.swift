import XCTest
@testable import ToyotaApp

@MainActor
final class FlowsTests: XCTestCase {
    private let service = InfoService()

    func testAuthFlowFabrics() {
        let authModule = AuthFlow.authModule(.init(
            scenario: .register, service: NewInfoService()
        ))
        XCTAssertTrue(authModule is AuthViewController)

        let codeModule = AuthFlow.codeModule(.init(
            phone: "", scenario: .register, service: NewInfoService()
        ))
        XCTAssertTrue(codeModule is SmsCodeViewController)
    }

    func testAuthModuleOutput() {
        let payload = AuthFlow.AuthPayload(
            scenario: .register, service: NewInfoService()
        )
        let module = AuthFlow.authModule(payload)
        testOutputable(module: module)
    }

    func testCodeModuleOutput() {
        let payload = AuthFlow.CodePayload(
            phone: "", scenario: .register, service: NewInfoService()
        )
        let module = AuthFlow.codeModule(payload)
        testOutputable(module: module)
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
        let tab = MainMenuFlow.entryPoint(.makeDefault(from: .mock))
        XCTAssertTrue(tab.root is MainTabBarController)
        XCTAssertTrue(tab.tabsRoots[.news]?.topViewController is NewsViewController)
        XCTAssertTrue(tab.tabsRoots[.services]?.topViewController is ServicesViewController)
        XCTAssertTrue(tab.tabsRoots[.profile]?.topViewController is ProfileViewController)
    }

    func testMainMenuFlowFabrics() throws {
        let chat = MainMenuFlow.chatModule()
        XCTAssertTrue(chat is ChatViewController)

        let payload = MainMenuFlow.ServicesPayload(
            user: .mock, service: service
        )
        let services = MainMenuFlow.servicesModule(payload)
        XCTAssertTrue(services is ServicesViewController)

        let payload1 = MainMenuFlow.ProfilePayload(
            user: .mock, service: service
        )
        let profile = MainMenuFlow.profileModule(payload1)
        XCTAssertTrue(profile is ProfileViewController)

        let payload2 = MainMenuFlow.BookingsPayload(
            userId: "-1", service: service
        )
        let bookings = MainMenuFlow.bookingsModule(payload2)
        XCTAssertTrue(bookings is BookingsViewController)

        let payload3 = MainMenuFlow.SettingsPayload(
            user: .mock, notificator: .shared
        )
        let settings = MainMenuFlow.settingsModule(payload3)
        XCTAssertTrue(settings is SettingsViewController)

        let payload4 = MainMenuFlow.ManagersPayload(
            userId: "-1", service: service
        )
        let managers = MainMenuFlow.managersModule(payload4)
        XCTAssertTrue(managers is ManagersViewController)

        let payload5 = MainMenuFlow.CarsPayload(
            user: .mock, service: service
        )
        let cars = MainMenuFlow.carsModule(payload5)
        XCTAssertTrue(cars is CarsViewController)

        let payload6 = MainMenuFlow.NewsPayload(
            service: NewsInfoService(), defaults: DefaultsService.shared
        )
        let news = MainMenuFlow.newsModule(payload6)
        XCTAssertTrue(news is NewsViewController)
    }

    func testSettingsModuleOutput() {
        let payload = MainMenuFlow.SettingsPayload(
            user: .mock, notificator: .shared
        )
        let module = MainMenuFlow.settingsModule(payload)
        testOutputable(module: module)
    }

    func testProfileModuleOutput() {
        let payload = MainMenuFlow.ProfilePayload(
            user: .mock, service: service
        )
        let module = MainMenuFlow.profileModule(payload)
        testOutputable(module: module)
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

// MARK: - Helpers
extension FlowsTests {
    func testOutputable<TModule: Outputable>(
        module: TModule
    ) where TModule.TOutput: Hashable & CaseIterable {
        var expectations = [TModule.TOutput: Bool]()
        module.withOutput { expectations[$0] = true }
        module.sendAllOutputs()
        XCTAssertTrue(expectations.count == TModule.TOutput.allCases.count)
        XCTAssertTrue(expectations.allSatisfy(\.value))
    }
}

private extension Outputable where TOutput: CaseIterable {
    func sendAllOutputs() {
        for item in TOutput.allCases {
            output?(item)
        }
    }
}

// MARK: - Mocks
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

#if DEBUG
extension ProfileOutput: CaseIterable {
    public static var allCases: [ProfileOutput] {
        [.logout, .showBookings, .showCars, .showManagers, .showSettings]
    }
}

extension AuthModuleOutput: CaseIterable {
    public static var allCases: [AuthModuleOutput] {
        [.showAgreement, .successPhoneCheck("", .register)]
    }
}

extension SettingsOutput: CaseIterable {
    public static var allCases: [SettingsOutput] {
        [.showAgreement, .changePhone(.empty)]
    }
}

extension SmsCodeModuleOutput: CaseIterable {
    public static var allCases: [SmsCodeModuleOutput] {
        [.successfulCheck(.register, nil)]
    }
}
#endif
