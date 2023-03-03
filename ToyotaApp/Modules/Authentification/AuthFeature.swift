import Foundation
import ComposableArchitecture

struct AuthFeature: ReducerProtocol {
    struct State: Equatable {
        let scenario: AuthScenario

        var phone: String = .empty
        var isValid: Bool = true
        var isLoading: Bool = false
        var popupMessage: String?
    }

    enum Action: Equatable {
        case phoneChanged(_ text: String)
        case sendButtonDidPress(_ validatedPhone: String?)
        case makeRequest(_ phone: String)
        case successfulPhoneSend(_ phone: String)
        case failurePhoneSend(_ message: String)
        case showAgreement
        case popupDidShow
    }

    enum Output: Hashable {
        case showAgreement
        case successPhoneCheck(_ phone: String, _ authScenario: AuthScenario)
    }

    let registerPhone: (_ body: RegisterPhoneBody) async -> DefaultResponse
    let storeInKeychain: (String) -> Void
    let outputStore: OutputStore<Output>

    // MARK: - Reduce
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .phoneChanged(text):
            state.phone = text
            state.isValid = true
            return .none
        case let .sendButtonDidPress(validated):
            guard let phone = validated else {
                state.isValid = false
                return .none
            }

            return .merge(
                .send(.phoneChanged(phone)),
                .send(.makeRequest(phone))
            )
        case .makeRequest:
            state.isLoading = true
            return .task { [phone = state.phone] in
                switch await registerPhone(.init(phone: phone)) {
                case .success:
                    return .successfulPhoneSend(phone)
                case let .failure(error):
                    return .failurePhoneSend(
                        error.message ?? .error(.unknownError)
                    )
                }
            }
        case let .failurePhoneSend(message):
            state.isLoading = false
            state.popupMessage = message
            return .send(.popupDidShow)
        case let .successfulPhoneSend(phone):
            state.isLoading = false
            if case .register = state.scenario {
                storeInKeychain(phone)
            }
            return .fireAndForget { [scenario = state.scenario] in
                outputStore.output?(.successPhoneCheck(phone, scenario))
            }
        case .showAgreement:
            guard state.scenario == .register else {
                return .none
            }

            return .fireAndForget {
                outputStore.output?(.showAgreement)
            }
        case .popupDidShow:
            state.popupMessage = nil
            return .none
        }
    }
}
