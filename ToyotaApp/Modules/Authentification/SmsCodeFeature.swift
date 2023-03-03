import Foundation
import ComposableArchitecture

struct SmsCodeFeature: ReducerProtocol {
    struct State: Equatable {
        let scenario: AuthScenario
        let phone: String

        var code: String = .empty
        var isValid: Bool = true
        var isLoading: Bool = false
        var popupMessage: String?
    }

    enum Action: Equatable {
        case codeDidChange(_ code: String)
        case checkCode(_ code: String)
        case makeRequest(_ code: String)
        case successfulCodeCheck(AuthScenario, CheckUserOrSmsCodeResponse?)
        case storeResponseData(CheckUserOrSmsCodeResponse?)
        case failureCodeCheck(_ message: String)
        case deleteTemporaryPhone
        case popupDidShow
    }

    enum Output: Equatable {
        case successfulCodeCheck(AuthScenario, CheckUserContext?)
    }

    // MARK: Environment
    let outputStore: OutputStore<Output>
    let storeInKeychain: (any Keychainable) -> Void
    let deleteTemporaryPhoneRequest: (_ phone: String) async -> Void
    let checkCodeRequest: (
        _ code: String,
        _ scenario: AuthScenario
    ) async -> Result<CheckUserOrSmsCodeResponse?, ErrorResponse>

    // MARK: - Reduce
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .codeDidChange(code):
            state.code = code
            state.isValid = true
            return .none
        case let .checkCode(code):
            guard code.count == 4, code.allSatisfy(\.isNumber) else {
                state.isValid = false
                return .none
            }

            return EffectTask(value: .makeRequest(code))
        case let .makeRequest(code):
            state.isLoading = true
            return .task { [scenario = state.scenario] in
                switch await checkCodeRequest(code, scenario) {
                case let .success(response):
                    return .successfulCodeCheck(scenario, response)
                case let .failure(error):
                    return .failureCodeCheck(
                        error.message ?? .error(.requestError)
                    )
                }
            }
        case let .successfulCodeCheck(scenario, response):
            state.isLoading = false
            return .merge(
                .send(.storeResponseData(response)),
                .fireAndForget {
                    outputStore.output?(
                        .successfulCodeCheck(scenario, .init(response))
                    )
                }
            )
        case let .storeResponseData(response):
            return .fireAndForget {
                if let secretKey = response?.secretKey {
                    storeInKeychain(SecretKey(secretKey))
                }
                if let userId = response?.userId {
                    storeInKeychain(UserId(userId))
                }
            }
        case let .failureCodeCheck(message):
            state.isLoading = false
            state.popupMessage = message
            return .send(.popupDidShow)
        case .deleteTemporaryPhone:
            return .fireAndForget { [phone = state.phone] in
                Task.detached {
                    await deleteTemporaryPhoneRequest(phone)
                }
            }
        case .popupDidShow:
            state.popupMessage = nil
            return .none
        }
    }
}
