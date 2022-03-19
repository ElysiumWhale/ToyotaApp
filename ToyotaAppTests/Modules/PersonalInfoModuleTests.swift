import XCTest
@testable import ToyotaApp

class PersonalInfoVCTest: XCTestCase {
    var controller: PersonalInfoViewController!

    override func setUpWithError() throws {
        let navVC = RegisterFlow.entryPoint() as? UINavigationController
        controller = navVC?.topViewController as? PersonalInfoViewController
    }

    override func tearDownWithError() throws {
        controller = nil
    }

    func testExample() throws {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.router)
        XCTAssertNotNil(controller.interactor)
        var result = false
        if case .empty = controller.interactor!.state {
            result = true
        }
        XCTAssert(result)
    }
}

class ConfiguredPersonalInfoVCTest: XCTestCase {
    let firstName = "Valera"
    let lastName = "Ivanov"
    let secondName = "Ivanovich"
    let email = "aboba@aboba.com"
    let birthday = "2021-05-05"

    var configuredController: PersonalInfoViewController!

    override func setUpWithError() throws {
        let profile = Profile(phone: .empty,
                              firstName: firstName,
                              lastName: lastName,
                              secondName: secondName,
                              email: email,
                              birthday: birthday)

        configuredController = RegisterFlow.personalInfoModule(profile) as? PersonalInfoViewController
    }

    override func tearDownWithError() throws {
        configuredController = nil
    }

    func testExample() throws {
        XCTAssertNotNil(configuredController)
        XCTAssertNotNil(configuredController.router)
        XCTAssertNotNil(configuredController.interactor)
        var configuredResult = false
        if case .configured(let profile) = configuredController.interactor!.state {
            XCTAssertEqual(profile.firstName, firstName)
            XCTAssertEqual(profile.secondName, secondName)
            XCTAssertEqual(profile.lastName, lastName)
            XCTAssertEqual(profile.email, email)
            XCTAssertEqual(profile.birthday, birthday)
            configuredResult = true
        }
        XCTAssert(configuredResult)
    }
}
