import XCTest
@testable import ToyotaApp

final class PersonalInfoVCTest: XCTestCase {
    var controller: PersonalInfoView?

    override func setUpWithError() throws {
        controller = RegisterFlow.personalModule() as? PersonalInfoView
    }

    override func tearDownWithError() throws {
        controller = nil
    }

    func testModuleParts() throws {
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller?.interactor)
    }

    func testModuleState() throws {
        try testModuleParts()

        var result = false
        if case .empty = controller!.interactor.state {
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

    var configuredController: PersonalInfoView?

    override func setUpWithError() throws {
        let profile = Profile(phone: .empty,
                              firstName: firstName,
                              lastName: lastName,
                              secondName: secondName,
                              email: email,
                              birthday: birthday)

        configuredController = RegisterFlow.personalModule(profile) as? PersonalInfoView
    }

    override func tearDownWithError() throws {
        configuredController = nil
    }

    func testModuleParts() throws {
        XCTAssertNotNil(configuredController)
        XCTAssertNotNil(configuredController?.interactor)
    }

    func testModuleState() throws {
        try testModuleParts()

        var configuredResult = false
        if case .configured(let profile) = configuredController!.interactor.state {
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
