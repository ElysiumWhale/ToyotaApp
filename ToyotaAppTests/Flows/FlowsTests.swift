import XCTest
@testable import ToyotaApp

@MainActor
final class FlowsTests: XCTestCase {
    private let service = InfoService()
    private let newService = NewInfoService()

    func testAuthFlowFabrics() {
        let authModule = AuthFlow.authModule(.init(
            scenario: .register, service: newService
        ))
        XCTAssertTrue(authModule is AuthViewController)

        let codeModule = AuthFlow.codeModule(.init(
            phone: .empty,
            scenario: .register,
            service: newService
        ))
        XCTAssertTrue(codeModule is SmsCodeViewController)
    }

    func testAuthModuleOutput() {
        let payload = AuthFlow.AuthPayload(
            scenario: .register, service: newService
        )
        let module = AuthFlow.authModule(payload)
        testOutputable(module: module)
    }

    func testCodeModuleOutput() {
        let payload = AuthFlow.CodePayload(
            phone: .empty,
            scenario: .register,
            service: newService
        )
        let module = AuthFlow.codeModule(payload)
        testOutputable(module: module)
    }

    func testRegisterFlowFabrics() {
        let personalModule = RegisterFlow.personalModule(.init(
            profile: nil,
            service: service,
            keychain: KeychainService.shared
        ))
        XCTAssertTrue(personalModule is PersonalInfoView)

        let cityModule = RegisterFlow.cityModule(.init(
            cities: [],
            service: service,
            defaults: DefaultsService.shared
        ))
        XCTAssertTrue(cityModule is CityPickerViewController)

        let addCarModule = RegisterFlow.addCarModule(.init(
            scenario: .register,
            models: [],
            colors: [],
            service: service,
            keychain: KeychainService.shared
        ))
        XCTAssertTrue(addCarModule is AddCarViewController)

        let endRegisterModule = RegisterFlow.endRegistrationModule()
        XCTAssertTrue(endRegisterModule is EndRegistrationViewController)
    }

    func testPersonalModuleOutput() {
        let personalModule = RegisterFlow.personalModule(.init(
            profile: nil,
            service: service,
            keychain: KeychainService.shared
        ))
        testOutputable(module: personalModule)
    }

    func testCityPickerModuleOutput() {
        let cityPickerModule = RegisterFlow.cityModule(.init(
            cities: [],
            service: service,
            defaults: DefaultsService.shared
        ))
        testOutputable(module: cityPickerModule)
    }

    func testAddCarModuleOutput() {
        let addCarModule = RegisterFlow.addCarModule(.init(
            scenario: .register,
            models: [],
            colors: [],
            service: service,
            keychain: KeychainService.shared
        ))
        testOutputable(module: addCarModule)
    }

    func testMainMenuFlowEntryPoint() {
        let tab = MainMenuFlow.entryPoint(.makeDefault(from: .mock))
        XCTAssertTrue(tab.root is MainTabBarController)
        XCTAssertTrue(tab.tabsRoots[.news]?.topViewController is NewsViewController)
        XCTAssertTrue(tab.tabsRoots[.services]?.topViewController is ServicesViewController)
        XCTAssertTrue(tab.tabsRoots[.profile]?.topViewController is ProfileViewController)
    }

    func testMainMenuFlowFabrics() {
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
            userId: .empty, service: service
        )
        let bookings = MainMenuFlow.bookingsModule(payload2)
        XCTAssertTrue(bookings is BookingsViewController)

        let payload3 = MainMenuFlow.SettingsPayload(
            user: .mock, notificator: .shared
        )
        let settings = MainMenuFlow.settingsModule(payload3)
        XCTAssertTrue(settings is SettingsViewController)

        let payload4 = MainMenuFlow.ManagersPayload(
            userId: .empty, service: service
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

    func testUtilsFlowFabrics() {
        let connection = UtilsFlow.connectionLostModule()
        XCTAssertTrue(connection is LostConnectionViewController)

        let agreement = UtilsFlow.agreementModule()
        XCTAssertTrue(agreement is AgreementViewController)

        let splash = UtilsFlow.splashScreenModule()
        XCTAssertTrue(splash is SplashScreenViewController)
    }

    func testServicesFlow() {
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
        [
            .showAgreement,
            .successPhoneCheck(.empty, .register),
            .successPhoneCheck(.empty, .changeNumber(.empty))
        ]
    }
}

extension SettingsOutput: CaseIterable {
    public static var allCases: [SettingsOutput] {
        [.showAgreement, .changePhone(.empty)]
    }
}

extension SmsCodeModuleOutput: CaseIterable {
    public static var allCases: [SmsCodeModuleOutput] {
        [
            .successfulCheck(.register, nil),
            .successfulCheck(.changeNumber(.empty), nil)
        ]
    }
}

extension PersonalInfoOutput: CaseIterable {
    public static var allCases: [PersonalInfoOutput] {
        [.profileDidSet(.init(cities: [], models: [], colors: []))]
    }
}

extension CityPickerOutput: CaseIterable {
    public static var allCases: [CityPickerOutput] {
        [.cityDidPick(.init(id: .empty, name: .empty))]
    }
}

extension AddCarOutput: CaseIterable {
    public static var allCases: [AddCarOutput] {
        [.carDidAdd(.register), .carDidAdd(.update(with: .mock))]
    }
}
#endif
