import XCTest
@testable import ToyotaApp

@MainActor
final class PersonalInfoVCTest: XCTestCase {
    func testEmptyModuleState() throws {
        let controller = RegisterFlow.personalModule(.init(
            profile: nil,
            service: InfoService(),
            keychain: KeychainService.shared
        )) as? PersonalInfoView
        XCTAssertEqual(controller?.interactor.state, .empty)
    }

    func testConfiguredModuleState() throws {
        let controller = RegisterFlow.personalModule(.init(
            profile: .mock,
            service: InfoService(),
            keychain: KeychainService.shared
        )) as? PersonalInfoView
        XCTAssertEqual(controller?.interactor.state, .configured(with: .mock))
    }
}

extension Profile {
    static let mock = Profile(
        phone: "123",
        firstName: "Valera",
        lastName: "Ivanov",
        secondName: "Ivanovich",
        email: "aboba@aboba.com",
        birthday: "2021-05-05"
    )
}
