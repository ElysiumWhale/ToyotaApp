import XCTest
@testable import ToyotaApp

class FlowsTests: XCTestCase {

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
        let personalModule = RegisterFlow.personalInfoModule(.empty)
        XCTAssertTrue(personalModule is PersonalInfoViewController)

        let cityModule = RegisterFlow.cityModule([])
        XCTAssertTrue(cityModule is CityPickerViewController)

        let addCarModule = RegisterFlow.addCarModule()
        XCTAssertTrue(addCarModule is AddCarViewController)

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

        let connection = UtilsFlow.connectionLostModule()
        XCTAssertTrue(connection is ConnectionLostViewController)
    }
}

private extension Profile {
    static var empty: Self {
        Profile(phone: .empty,
                firstName: .empty,
                lastName: .empty,
                secondName: .empty,
                email: .empty,
                birthday: .empty)
    }
}
