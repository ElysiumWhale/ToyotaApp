import XCTest
import ComposableArchitecture
@testable import ToyotaApp

@MainActor
final class AuthFeatureTests: XCTestCase {
    func testPhoneChanged() async {
        let phone = "test"
        await testStore().send(.phoneChanged(phone)) {
            $0.phone = phone
            $0.isValid = true
        }
    }

    func testSendInvalidPhone() async {
        await testStore().send(.sendButtonDidPress(nil)) {
            $0.isValid = false
        }
    }

    func testSendValidPhoneFailure() async {
        let validPhone = "test"
        let errorMessage = "errorMessage"
        let store = testStore(
            registerPhone: { _ in
                .failure(ErrorResponse(
                    code: .request, message: errorMessage
                ))
            }
        )

        await store.send(.sendButtonDidPress(validPhone))
        await store.receive(.phoneChanged(validPhone)) {
            $0.phone = validPhone
            $0.isValid = true
        }
        await store.receive(.makeRequest(validPhone)) {
            $0.isLoading = true
        }
        await store.receive(.failurePhoneSend(errorMessage)) {
            $0.isLoading = false
            $0.popupMessage = errorMessage
        }
        await store.receive(.popupDidShow) {
            $0.popupMessage = nil
        }
    }

    func testSendValidPhoneSuccess() async {
        let validPhone = "test"
        var outputDidSend = false
        let output = OutputStore<Output>().withOutput { _ in
            outputDidSend = true
        }
        let store = testStore(
            state: State(scenario: .changeNumber(.empty)),
            registerPhone: { _ in
                .success(SimpleResponse(result: .empty))
            },
            storeInKeychain: { _ in XCTFail("No need to store in keychain") },
            outputStore: output
        )

        await store.send(.sendButtonDidPress(validPhone))
        await store.receive(.phoneChanged(validPhone)) {
            $0.phone = validPhone
            $0.isValid = true
        }
        await store.receive(.makeRequest(validPhone)) {
            $0.isLoading = true
        }
        await store.receive(.successfulPhoneSend(validPhone)) {
            $0.isLoading = false
        }
        XCTAssertTrue(outputDidSend)
    }

    func testShowAgreementRegister() async {
        var agreementDidShow = false
        let output = OutputStore<Output>().withOutput { _ in
            agreementDidShow = true
        }
        await testStore(outputStore: output).send(.showAgreement)
        XCTAssertTrue(agreementDidShow)
    }

    func testShowAgreementChangeNumber() async {
        let output = OutputStore<Output>().withOutput { _ in
            XCTFail("No need to show agreement")
        }
        await testStore(
            state: State(scenario: .changeNumber(.empty)),
            outputStore: output
        ).send(.showAgreement)
    }
}

private extension AuthFeatureTests {
    typealias State = AuthFeature.State
    typealias Action = AuthFeature.Action
    typealias Output = AuthFeature.Output
    typealias RegisterPhone = (RegisterPhoneBody) async -> DefaultResponse

    func testStore(
        state: State = State(scenario: .register),
        registerPhone: @escaping RegisterPhone = {
            _ in .success(SimpleResponse(result: .empty))
        },
        storeInKeychain: @escaping (String) -> Void = { _ in },
        outputStore: OutputStore<AuthFeature.Output> = OutputStore()
    ) -> TestStore<State, Action, State, Action, Void> {
        TestStore(
            initialState: state,
            reducer: AuthFeature(
                registerPhone: registerPhone,
                storeInKeychain: storeInKeychain,
                outputStore: outputStore
            )
        )
    }
}
