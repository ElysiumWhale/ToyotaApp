import XCTest
import ComposableArchitecture
@testable import ToyotaApp

@MainActor
final class PersonalInfoFeatureTests: XCTestCase {
    func testPersonDidChange() async {
        let fieldState = FieldState(value: "123", isValid: true)
        await testStore().send(.personDidChange(
            .firstName, fieldState
        )) {
            $0.personState[.firstName] = fieldState
        }
    }

    func testButtonDidPressWithNotValid() async {
        let store = testStore(state: State(
            userId: "1",
            personState: [.firstName: FieldState(value: "123", isValid: false)]
        ))
        await store.send(.actionButtonDidPress) {
            $0.needsValidation = true
            $0.popupMessage = .error(.checkInput)
        }
        await store.send(.fieldsDidValidate) { $0.needsValidation = false }
        await store.send(.popupDidShow) { $0.popupMessage = nil }
    }

    func testButtonDidPressValidFieldsFailure() async {
        let store = testStore(state: State(
            userId: "1",
            personState: .make(from: Profile.mock, isValid: true)
        ))
        await store.send(.actionButtonDidPress)
        await store.receive(.setPerson(Person.mock)) {
            $0.isLoading = true
        }
        await store.receive(.failureResponse(.corruptedData)) {
            $0.isLoading = false
            $0.popupMessage = ErrorResponse.corruptedData.message
        }
    }

    func testButtonDidPressValidFieldsSuccess() async {
        var didStoreInKeychain = false
        var didReceiveOutput = false
        let output = OutputStore<Output>().withOutput { _ in
            didReceiveOutput = true
        }
        let expectation = CitiesResponse(
            result: "ok", cities: [], models: [], colors: []
        )
        let store = testStore(
            state: State(
                userId: "1",
                personState: .make(from: Profile.mock, isValid: true)
            ),
            storeInKeychain: { _ in didStoreInKeychain = true },
            outputStore: output,
            setPerson: { _ in .success(expectation) }
        )
        await store.send(.actionButtonDidPress)
        await store.receive(.setPerson(Person.mock)) {
            $0.isLoading = true
        }
        await store.receive(.successResponse(expectation, Person.mock)) {
            $0.isLoading = false
        }
        XCTAssertTrue(didStoreInKeychain)
        XCTAssertTrue(didReceiveOutput)
    }
}

private extension PersonalInfoFeatureTests {
    typealias State = PersonalInfoFeature.State
    typealias Action = PersonalInfoFeature.Action
    typealias Output = PersonalInfoFeature.Output
    typealias SetPerson = (SetProfileBody) async -> NewResponse<CitiesResponse>
    typealias FieldState = PersonalInfoFeature.FieldState
    typealias Fields = PersonalInfoFeature.Fields

    func testStore(
        state: State = State(userId: "1", personState: [:]),
        storeInKeychain: @escaping (any Keychainable) -> Void = { _ in },
        outputStore: OutputStore<PersonalInfoFeature.Output> = OutputStore(),
        setPerson: @escaping SetPerson = { _ in .failure(.corruptedData) }
    ) -> TestStore<State, Action, State, Action, Void> {
        TestStore(
            initialState: state,
            reducer: PersonalInfoFeature(
                setPersonRequest: setPerson,
                storeInKeychain: storeInKeychain,
                outputStore: outputStore
            )
        )
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

extension Person {
    static let mock = Profile.mock.toDomain()
}
