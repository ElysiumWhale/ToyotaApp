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

        let entry = RegisterFlow.entryPoint(with: [personalModule,
                                                   cityModule,
                                                   addCarModule])
        XCTAssertTrue(entry is UINavigationController)
        let nvc = entry as? UINavigationController
        XCTAssertTrue(nvc!.topViewController is AddCarViewController)
    }

    func testMainMenuFlow() throws {
        let tab = MainMenuFlow.entryPoint(for: .mock)
        XCTAssertTrue(tab is MainTabBarController)

        let chat = MainMenuFlow.chatModule()
        XCTAssertTrue(chat is ChatViewController)

        let services = MainMenuFlow.servicesModule(with: .mock)
        XCTAssertTrue(services is ServicesViewController)

        let profile = MainMenuFlow.profileModule(with: .mock)
        XCTAssertTrue(profile is MyProfileViewController)

        let news = MainMenuFlow.newsModule()
        XCTAssertTrue(news is NewsViewController)

        let bookings = MainMenuFlow.bookingsModule()
        XCTAssertTrue(bookings is BookingsViewController)

        let settings = MainMenuFlow.settingsModule(user: .mock)
        XCTAssertTrue(settings is SettingsViewController)

        let managers = MainMenuFlow.managersModule(user: .mock)
        XCTAssertTrue(managers is ManagersViewController)
    }

    func testUtilsFlow() throws {
        let connection = UtilsFlow.connectionLostModule()
        XCTAssertTrue(connection is LostConnectionViewController)

        let agreement = UtilsFlow.agreementModule()
        XCTAssertTrue(agreement is AgreementViewController)

        let splash = UtilsFlow.splashScreenModule()
        XCTAssertTrue(splash is SplashScreenViewController)
    }
}
