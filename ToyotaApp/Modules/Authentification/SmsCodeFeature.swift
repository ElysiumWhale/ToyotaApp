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
        case output(Output)
        case failureCodeCheck(_ message: String)
        case deleteTemporaryPhone
        case popupDidShow
        case cancelTasks
    }

    enum Output: Equatable {
        case successfulCodeCheck(AuthScenario, CheckUserContext?)
    }

    enum TaskId { }

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
            }.cancellable(id: TaskId.self)
        case let .successfulCodeCheck(scenario, response):
            state.isLoading = false
            return .concatenate(
                .send(.storeResponseData(response)),
                .send(.output(.successfulCodeCheck(
                    scenario, CheckUserContext(response)
                )))
            )
        case let .storeResponseData(response):
            if let secretKey = response?.secretKey {
                storeInKeychain(SecretKey(value: secretKey))
            }
            if let userId = response?.userId {
                storeInKeychain(UserId(value: userId))
            }
            return .none
        case let .output(output):
            outputStore.output?(output)
            return .none
        case let .failureCodeCheck(message):
            state.isLoading = false
            state.popupMessage = message
            return .none
        case .deleteTemporaryPhone:
            return .fireAndForget { [phone = state.phone] in
                Task.detached {
                    await deleteTemporaryPhoneRequest(phone)
                }
            }
        case .popupDidShow:
            state.popupMessage = nil
            return .none
        case .cancelTasks:
            return .cancel(id: TaskId.self)
        }
    }
}
