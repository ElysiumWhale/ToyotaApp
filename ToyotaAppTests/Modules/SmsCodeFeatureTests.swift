import XCTest
import ComposableArchitecture
@testable import ToyotaApp

@MainActor
final class SmsCodeFeatureTests: XCTestCase {
    func testCodeChanged() async {
        let code = "3228"
        await testStore().send(.codeDidChange(code)) {
            $0.code = code
            $0.isValid = true
        }
    }

    func testCheckInvalidCode() async {
        let tooShortCode = "12"
        await testStore().send(.checkCode(tooShortCode)) {
            $0.isValid = false
        }

        let notAllDigitsCode = "a1b2"
        await testStore().send(.checkCode(notAllDigitsCode)) {
            $0.isValid = false
        }
    }

    func testCheckValidCodeFailure() async {
        let code = "3228"
        let message = "test"
        let store = testStore(checkCode: { _, _ in
            .failure(ErrorResponse(code: .request, message: message))
        })

        await store.send(.checkCode(code))
        await store.receive(.makeRequest(code)) {
            $0.isLoading = true
        }
        await store.receive(.failureCodeCheck(message)) {
            $0.isLoading = false
            $0.popupMessage = message
        }
        await store.receive(.popupDidShow) {
            $0.popupMessage = nil
        }
    }

    func testCheckValidCodeSuccess() async {
        var responseDidStore = false
        var outputDidSend = false

        let mockResponse = CheckUserOrSmsCodeResponse.mock
        let code = "3228"
        let store = testStore(
            storeInKeychain: { _ in responseDidStore = true },
            outputStore: OutputStore().withOutput { _ in
                outputDidSend = true
            },
            checkCode: { _, _ in .success(mockResponse) }
        )

        await store.send(.checkCode(code))
        await store.receive(.makeRequest(code)) {
            $0.isLoading = true
        }
        await store.receive(.successfulCodeCheck(.register, mockResponse)) {
            $0.isLoading = false
        }
        await store.receive(.storeResponseData(mockResponse))

        XCTAssertTrue(responseDidStore)
        XCTAssertTrue(outputDidSend)
    }

    func testDeleteTemporaryPhone() async {
        var phoneDidDelete = false
        await testStore(
            deleteTemporary: { _ in phoneDidDelete = true }
        ).send(.deleteTemporaryPhone)

        XCTAssertTrue(phoneDidDelete)
    }
}

private extension SmsCodeFeatureTests {
    typealias State = SmsCodeFeature.State
    typealias Action = SmsCodeFeature.Action
    typealias Output = SmsCodeFeature.Output
    typealias CheckCode = (String, AuthScenario) async -> Result<CheckUserOrSmsCodeResponse?, ErrorResponse>

    func testStore(
        state: State = State(scenario: .register, phone: "123"),
        storeInKeychain: @escaping (any Keychainable) -> Void = { _ in },
        outputStore: OutputStore<SmsCodeFeature.Output> = OutputStore(),
        checkCode: @escaping CheckCode = { _, _ in .success(nil) },
        deleteTemporary: @escaping (String) async -> Void = { _ in }
    ) -> TestStore<State, Action, State, Action, Void> {
        TestStore(
            initialState: state,
            reducer: SmsCodeFeature(
                outputStore: outputStore,
                storeInKeychain: storeInKeychain,
                deleteTemporaryPhoneRequest: deleteTemporary,
                checkCodeRequest: checkCode
            )
        )
    }
}

#if DEBUG
private extension CheckUserOrSmsCodeResponse {
    static var mock: CheckUserOrSmsCodeResponse {
        CheckUserOrSmsCodeResponse(
            result: .empty,
            secretKey: "mock",
            userId: "mock",
            registerPage: nil,
            registeredUser: nil,
            registerStatus: nil,
            cities: nil,
            models: nil,
            colors: nil
        )
    }
}
#endif
