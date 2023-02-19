import XCTest
@testable import ToyotaApp

final class CheckUserContextTests: XCTestCase {
    func testEmpty() {
        let response1 = mockResponse(
            registerPage: 1,
            registerStatus: 1
        )
        XCTAssertEqual(
            CheckUserContext(response: response1),
            .empty
        )

        let response2 = mockResponse(registerPage: 3)
        XCTAssertEqual(
            CheckUserContext(response: response2),
            .empty
        )
    }

    func testStartRegister() {
        let response1 = mockResponse()
        XCTAssertEqual(
            CheckUserContext(response: response1),
            .startRegister
        )

        let response2 = mockResponse(registerPage: 1)
        XCTAssertEqual(
            CheckUserContext(response: response2),
            .startRegister
        )
    }

    func testRegister() {
        let response1 = mockResponse(
            registerPage: 2,
            registeredUser: .init(profile: .mock, cars: []),
            cities: []
        )
        XCTAssertEqual(
            CheckUserContext(response: response1),
            .register(2, .init(profile: .mock, cars: []), [])
        )
    }

    func testMain() {
        let response1 = mockResponse(
            registerStatus: 1
        )
        XCTAssertEqual(
            CheckUserContext(response: response1),
            .main(nil)
        )

        let response2 = mockResponse(
            registeredUser: .init(profile: .mock, cars: []),
            registerStatus: 1
        )
        XCTAssertEqual(
            CheckUserContext(response: response2),
            .main(.init(profile: .mock, cars: []))
        )
    }
}

private extension CheckUserContextTests {
    func mockResponse(
        result: String = .empty,
        secretKey: String = .empty,
        userId: String? = nil,
        registerPage: Int? = nil,
        registeredUser: RegisteredUser? = nil,
        registerStatus: Int? = nil,
        cities: [City]? = nil,
        models: [Model]? = nil,
        colors: [Color]? = nil
    ) -> CheckUserOrSmsCodeResponse {
        .init(
            result: result,
            secretKey: secretKey,
            userId: userId,
            registerPage: registerPage,
            registeredUser: registeredUser,
            registerStatus: registerStatus,
            cities: cities,
            models: models,
            colors: colors
        )
    }
}
