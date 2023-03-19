import ComposableArchitecture
import Foundation

struct PersonalInfoFeature: ReducerProtocol {
    struct State: Equatable {
        let userId: String

        var personState: [Fields: FieldState] = [
            .firstName: FieldState(value: "", isValid: false),
            .secondName: FieldState(value: "", isValid: false),
            .lastName: FieldState(value: "", isValid: false),
            .email: FieldState(value: "", isValid: false),
            .birth: FieldState(value: "", isValid: false)
        ]
        var needsValidation = false
        var isLoading = false
        var popupMessage: String?
    }

    enum Fields: Hashable {
        case firstName
        case secondName
        case lastName
        case email
        case birth
    }

    struct FieldState: Equatable {
        let value: String?
        let isValid: Bool
    }

    enum Action: Equatable {
        case actionButtonDidPress
        case setPerson(Person)
        case successResponse(CitiesResponse, Person)
        case failureResponse(ErrorResponse)
        case popupDidShow
        case fieldsDidValidate
        case personDidChange(Fields, FieldState)
    }

    enum Output: Equatable {
        struct Payload: Hashable {
            let cities: [City]
            let models: [Model]
            let colors: [Color]
        }

        case personDidSet(_ response: Payload)
    }

    let setPersonRequest: (SetProfileBody) async -> NewResponse<CitiesResponse>
    let storeInKeychain: (any Keychainable) -> Void
    let outputStore: OutputStore<Output>

    // MARK: - Reduce
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .personDidChange(field, fieldState):
            state.personState[field] = fieldState
            return .none
        case .fieldsDidValidate:
            state.needsValidation = false
            return .none
        case .popupDidShow:
            state.popupMessage = nil
            return .none
        case .actionButtonDidPress:
            guard state.personState.values.allSatisfy(\.isValid) else {
                state.needsValidation = true
                state.popupMessage = .error(.checkInput)
                return .none
            }
            let person = Person(
                firstName: state.personState[.firstName]?.value,
                lastName: state.personState[.lastName]?.value,
                secondName: state.personState[.secondName]?.value,
                email: state.personState[.email]?.value,
                birthday: state.personState[.birth]?.value
            )
            return .send(.setPerson(person))
        case let .setPerson(request):
            state.isLoading = true
            return .task { [userId = state.userId] in
                switch await setPersonRequest(SetProfileBody(
                    brandId: Brand.Toyota,
                    userId: userId,
                    firstName: request.firstName,
                    secondName: request.secondName,
                    lastName: request.lastName,
                    email: request.email,
                    birthday: request.birthday
                )) {
                case let .failure(error):
                    return .failureResponse(error)
                case let .success(response):
                    return .successResponse(response, request)
                }
            }
        case let .successResponse(response, person):
            state.isLoading = false
            storeInKeychain(person)
            return .fireAndForget {
                outputStore.output?(.personDidSet(Output.Payload(
                    cities: response.cities,
                    models: response.models ?? [],
                    colors: response.colors ?? []
                )))
            }
        case let .failureResponse(error):
            state.isLoading = false
            state.popupMessage = error.message ?? .error(.requestError)
            return .none
        }
    }
}

typealias Fields = PersonalInfoFeature.Fields
typealias FieldState = PersonalInfoFeature.FieldState

extension Dictionary where Key == Fields, Value == FieldState {
    static func make(from profile: Profile?, isValid: Bool = false) -> Self {
        [
            .firstName: FieldState(value: profile?.firstName, isValid: isValid),
            .secondName: FieldState(value: profile?.secondName, isValid: isValid),
            .lastName: FieldState(value: profile?.lastName, isValid: isValid),
            .email: FieldState(value: profile?.email, isValid: isValid),
            .birth: FieldState(value: profile?.birthday, isValid: isValid),
        ]
    }
}
