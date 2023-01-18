import XCTest
@testable import ToyotaApp

final class PersonalInfoVCTest: XCTestCase {
    func testEmptyModuleState() throws {
        let controller = RegisterFlow.personalModule() as? PersonalInfoView
        XCTAssertEqual(controller?.interactor.state, .empty)
    }

    func testConfiguredModuleState() throws {
        let controller = RegisterFlow.personalModule(.mock) as? PersonalInfoView
        XCTAssertEqual(controller?.interactor.state, .configured(with: .mock))
    }
}

private extension Profile {
    static var mock: Profile {
        .init(
            phone: "123",
            firstName: "Valera",
            lastName: "Ivanov",
            secondName: "Ivanovich",
            email: "aboba@aboba.com",
            birthday: "2021-05-05"
        )
    }
}
